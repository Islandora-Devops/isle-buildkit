import com.bmuschko.gradle.docker.tasks.image.DockerPushImage

plugins {
    id("com.bmuschko.docker-remote-api") version "6.4.0"
}

extensions.findByName("buildScan")?.withGroovyBuilder {
    setProperty("termsOfServiceUrl", "https://gradle.com/terms-of-service")
    setProperty("termsOfServiceAgree", "yes")
}

val repository: String by project

subprojects {
    // Make all build directories relative to the root, only supports projects up to a depth of one for now.
    buildDir = rootProject.buildDir.resolve(projectDir.relativeTo(rootDir))
    layout.buildDirectory.set(buildDir)

    // If there is a docker file in the project add the appropriate tasks.
    if (projectDir.resolve("Dockerfile").exists()) {
        apply(plugin = "com.bmuschko.docker-remote-api")
        val tags: String by project
        val image = "$repository/$name"

        val imageTags = setOf(
                "$image:latest",
                "$image:${version}"
        ) + tags.split(' ').filter { it.isNotEmpty() }.map { "$image:$it" }

        val buildDockerImage = tasks.register<DockerBuildImage>("build") {
            group = "islandora"
            description = "Creates Docker image."
            images.addAll(imageTags)
            inputDir.set(projectDir)
        }

        tasks.register<DockerPushImage>("push") {
            images.set(buildDockerImage.map { it.images.get() })
        }
    }
}

// https://docs.docker.com/engine/reference/builder/#from
// FROM [--platform=<platform>] <image> [AS <name>]
// FROM [--platform=<platform>] <image>[:<tag>] [AS <name>]
// FROM [--platform=<platform>] <image>[@<digest>] [AS <name>]
val extractProjectDependenciesFromDockerfileRegex = """FROM[ \t]+(:?--platform=[^ ]+[ \t]+)?islandora/([^ :@]+)""".toRegex()
subprojects {
    tasks.withType<DockerBuildImage> {
        val contents = inputDir.get().asFile.resolve("Dockerfile").readText()
        // Extract the image name without the prefix 'islandora' it should match an existing project.
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
                    }
        }
    }
}

//=============================================================================
// Helper functions.
//=============================================================================

// Override the DockerBuildImage command to use the CLI since BuildKit is not supported in the java docker api.
// https://github.com/docker-java/docker-java/issues/1381
open class DockerBuildImage : DefaultTask() {
    @InputDirectory
    @PathSensitive(PathSensitivity.RELATIVE)
    val inputDir = project.objects.directoryProperty()

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

    @TaskAction
    fun exec() {
        val command = mutableListOf("docker", "build")
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
