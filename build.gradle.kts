import com.bmuschko.gradle.docker.tasks.image.DockerBuildImage
import com.bmuschko.gradle.docker.tasks.image.DockerPushImage
import com.bmuschko.gradle.docker.tasks.image.Dockerfile
import com.bmuschko.gradle.docker.tasks.image.Dockerfile.*
import java.lang.RuntimeException

plugins {
    id("com.bmuschko.docker-remote-api") version "6.4.0"
}

extensions.findByName("buildScan")?.withGroovyBuilder {
    setProperty("termsOfServiceUrl", "https://gradle.com/terms-of-service")
    setProperty("termsOfServiceAgree", "yes")
}

val useBuildKit: String by project
val repository: String by project
val cacheRepository: String by project

val registryUrl: String by project
val registryUsername: String by project
val registryPassword: String by project

// https://docs.docker.com/engine/reference/builder/#from
// FROM [--platform=<platform>] <image> [AS <name>]
// FROM [--platform=<platform>] <image>[:<tag>] [AS <name>]
// FROM [--platform=<platform>] <image>[@<digest>] [AS <name>]
val extractProjectDependenciesFromDockerfileRegex = """FROM[ \t]+(:?--platform=[^ ]+[ \t]+)?local/([^ :@]+):(.*)""".toRegex()

// If Buildkit is enabled instructions are left as is otherwise Buildkit specific flags are removed.
val extractBuildkitFlagFromInstruction = """(--mount.+ \\)""".toRegex()
val preprocessRunInstruction: (Instruction) -> Instruction = if (useBuildKit.toBoolean()) {
    // No-op
    { instruction -> instruction }
} else {
    // Strip Buildkit specific flags.
    { instruction ->
        // Assumes only mount flags are used and each one is separated onto it's own line.
        val text = instruction.text.replace(extractBuildkitFlagFromInstruction, """\\""")
        GenericInstruction(text)
    }
}

data class BindMount(val from: String, val source: String, val target: String) {
    companion object {
        private val EXTRACT_BIND_MOUNT_REGEX = """--mount=type=bind,([^\\]+)""".toRegex()

        fun fromInstruction(instruction: Instruction) = EXTRACT_BIND_MOUNT_REGEX.find(instruction.text)?.let {
                val properties = it.groupValues[1].split(',').map { property ->
                    val parts = property.split('=')
                    Pair(parts[0], parts[1])
                }.toMap()
                BindMount(properties["from"]!!, properties["source"]!!, properties["target"]!!)
            }
    }
    // eg. COPY --from=imagemagick /home/builder/packages/x86_64 /packages
    fun toCopyInstruction() = GenericInstruction("COPY --from=${from} $source $target")
}

fun extractBindMountFlagFromInstruction() {

}
//--mount=type=bind,from=imagemagick,source=/home/builder/packages/x86_64,target=/packages
// Generate a list of image tages for the given image, using the project, version and tag properties.
fun imagesTags(image: String, project: Project): Set<String> {
    val tags: String by project
    return setOf(
        "$image:latest",
        "$image:${project.version}"
    ) + tags.split(' ').filter { it.isNotEmpty() }.map { "$image:$it" }
}

subprojects {
    // Make all build directories relative to the root, only supports projects up to a depth of one for now.
    buildDir = rootProject.buildDir.resolve(projectDir.relativeTo(rootDir))
    layout.buildDirectory.set(buildDir)

    // If there is a docker file in the project add the appropriate tasks.
    if (projectDir.resolve("Dockerfile").exists()) {
        apply(plugin = "com.bmuschko.docker-remote-api")
        
        val imageTags = imagesTags("$repository/$name", project)
        val cachedImageTags = imagesTags("$cacheRepository/$name", project)

        val createDockerfile = tasks.register<Dockerfile>("createDockerFile") {
            instructionsFromTemplate(projectDir.resolve("Dockerfile"))
            // To simplify processing the instructions group them by keyword.
            val originalInstructions = instructions.get().toList()
            val groupedInstructions = mutableListOf<Pair<String, MutableList<Instruction>>>(
                    Pair(originalInstructions.first().keyword, mutableListOf(originalInstructions.first()))
            )
            originalInstructions.drop(1).forEach { instruction ->
                // An empty keyword means the line of text belongs to the previous instruction keyword.
                if (instruction.keyword != "") {
                    groupedInstructions.add(Pair(instruction.keyword, mutableListOf(instruction)))
                }
                else {
                    groupedInstructions.last().second.add(instruction)
                }
            }
            // Using bind mounts from other images needs to be mapped to COPY instructions, if not using Buildkit.
            // Add these COPY instructions prior to the RUN instructions that used the bind mount.
            val iterator = groupedInstructions.listIterator()
            while(iterator.hasNext()) {
                val (keyword, instructions) = iterator.next()
                when (keyword) {
                    RunCommandInstruction.KEYWORD -> {
                        // Get any bind mount flags and convert them into copy instructions.
                        val bindMounts = instructions.mapNotNull { instruction->
                            BindMount.fromInstruction(instruction)
                        }
                        bindMounts.forEach { bindMount ->
                            // Add before RUN instruction, previous is safe here as there has to always be at least a
                            // single FROM instruction preceeding it.
                            iterator.previous()
                            iterator.add(Pair(CopyFileInstruction.KEYWORD, mutableListOf(bindMount.toCopyInstruction())))
                            iterator.next()
                        }
                    }
                }
            }
            // Process instructions in place, and flatten to list.
            val processedInstructions = groupedInstructions.flatMap { (keyword, instructions) ->
                    when (keyword) {
                        // Use the 'repository' name for the images when building, defaults to 'local'.
                        FromInstruction.KEYWORD -> {
                            instructions.map { instruction ->
                                extractProjectDependenciesFromDockerfileRegex.find(instruction.text)?.let {
                                    val name = it.groupValues[2]
                                    val remainder = it.groupValues[3]
                                    FromInstruction(From("$repository/$name:$remainder"))
                                } ?: instruction
                            }
                        }
                        // Strip Buildkit flags if applicable.
                        RunCommandInstruction.KEYWORD -> instructions.map { preprocessRunInstruction(it) }
                        else -> instructions
                    }
                }
            instructions.set(processedInstructions)
            destFile.set(buildDir.resolve("Dockerfile"))
        }

        val prepareContext = tasks.register<Sync>("prepareContext") {
            from(projectDir)
            from(createDockerfile.map { it.destFile.get() })
            into(buildDir.resolve("context"))
        }

        val buildDockerImage = if (useBuildKit.toBoolean()) {
            tasks.register<DockerBuildKitBuildImage>("build") {
                group = "islandora"
                description = "Creates Docker image."
                images.addAll(imageTags)
                inputDir.set(layout.dir(prepareContext.map { it.destinationDir }))
                // Use the remote cache to build this image if possible.
                cacheFrom.addAll(cachedImageTags)
                // Allow image to be used as a cache when building on other machine.
                buildArgs.put("BUILDKIT_INLINE_CACHE", "1")
            }
        } else {
            tasks.register<DockerBuildImage>("build") {
                group = "islandora"
                description = "Creates Docker image."
                images.addAll(imageTags)
                inputDir.set(layout.dir(prepareContext.map { it.destinationDir }))
            }
        }

        tasks.register<DockerPushImage>("push") {
            images.set(buildDockerImage.map {
                when (it) {
                    is DockerBuildKitBuildImage -> it.images.get()
                    is DockerBuildImage -> it.images.get()
                    else -> throw RuntimeException("Impossible to reach this state, but we must satisfy the type system.")
                }
            })
            registryCredentials {
                url.set(registryUrl)
                username.set(registryUsername)
                password.set(registryPassword)
            }
        }
    }
}

subprojects {
    tasks.withType<DockerBuildImage> {
        val contents = projectDir.resolve("Dockerfile").readText()
        // Extract the image name without the prefix 'local' it should match an existing project.
        val matches = extractProjectDependenciesFromDockerfileRegex.findAll(contents)

        // If the project is found and it has a build task, link the dependency.
        matches.forEach {
            rootProject.findProject(it.groupValues[2])
                    ?.tasks
                    ?.withType<DockerBuildImage>()
                    ?.first()
                    ?.let { buildTask ->
                        // If generated image id changes, rebuild.
                        inputs.file(buildTask.imageIdFile.asFile)
                        dependsOn(buildTask)
                        // This used to replace the FROM statements such that the referred to the Image ID rather
                        // than "latest". Though this is currently broken when BuildKit is enabled:
                        // https://github.com/moby/moby/issues/39769
                        // Now it uses whatever repository we're building / latest since that is variable.
                    }
        }
    }
}

//=============================================================================
// Helper functions.
//=============================================================================

// Override the DockerBuildImage command to use the CLI since BuildKit is not supported in the java docker api.
// https://github.com/docker-java/docker-java/issues/1381
open class DockerBuildKitBuildImage : DefaultTask() {
    @InputDirectory
    @PathSensitive(PathSensitivity.RELATIVE)
    val inputDir = project.objects.directoryProperty()

    @Input
    @get:Optional
    val cacheFrom = project.objects.listProperty<String>()

    @Input
    @get:Optional
    val buildArgs = project.objects.mapProperty<String, String>()

    @Input
    @get:Optional
    val images = project.objects.setProperty<String>()

    @OutputFile
    val imageIdFile = project.objects.fileProperty()

    @Internal
    val imageId = project.objects.property<String>()

    init {
        logging.captureStandardOutput(LogLevel.INFO)
        logging.captureStandardError(LogLevel.ERROR)
        imageIdFile.set(project.buildDir.resolve(".docker/${path.replace(":", "_")}-imageId.txt"))
    }

    private fun cacheFromValid(image: String): Boolean {
        return try {
            val result = project.exec {
                environment("DOCKER_CLI_EXPERIMENTAL", "enabled")
                workingDir = inputDir.get().asFile
                commandLine = listOf("docker", "manifest", "inspect", image)
            }
            result.exitValue == 0;
        }
        catch (e: Exception) {
            logger.error("Failed to find cache image: ${image}, either it does not exist, or authentication failed.")
            false
        }
    }

    @TaskAction
    fun exec() {
        val command = mutableListOf("docker", "build")
        command.addAll(cacheFrom.get().filter { cacheFromValid(it) }.flatMap { listOf("--cache-from", it) })
        command.addAll(buildArgs.get().flatMap { listOf("--build-arg", "${it.key}=${it.value}") })
        command.addAll(images.get().flatMap { listOf("--tag", it) })
        command.addAll(listOf("--iidfile", imageIdFile.get().asFile.absolutePath))
        command.add(".")
        project.exec {
            environment("DOCKER_BUILDKIT" to 1)
            workingDir = inputDir.get().asFile
            commandLine = command
        }
        imageId.set(imageIdFile.map { it.asFile.readText() })
    }
}
