package plugins

import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.databind.DeserializationFeature
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import com.fasterxml.jackson.module.kotlin.KotlinModule
import com.fasterxml.jackson.module.kotlin.readValue
import org.gradle.api.DefaultTask
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.file.RegularFileProperty
import org.gradle.api.logging.LogLevel.*
import org.gradle.api.services.BuildService
import org.gradle.api.services.BuildServiceParameters
import org.gradle.api.tasks.*
import org.gradle.kotlin.dsl.*
import org.gradle.nativeplatform.platform.internal.DefaultNativePlatform
import plugins.DockerPlugin.Companion.normalizeDockerTag
import plugins.IslePlugin.Companion.isDockerProject
import plugins.RegistryPlugin.Companion.isleLocalRegistryDomain
import plugins.SharedPropertiesPlugin.Companion.branch
import plugins.SharedPropertiesPlugin.Companion.isLatestTag
import plugins.SharedPropertiesPlugin.Companion.sourceDateEpoch
import plugins.SharedPropertiesPlugin.Companion.tag
import tasks.DockerContainer
import tasks.DockerNetwork
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.OutputStream.nullOutputStream
import java.io.Serializable


@Suppress("unused")
class BuildPlugin : Plugin<Project> {

    companion object {
        // The driver to use for the build, either "docker", "docker-container", or
        // "kubernetes". Note that "docker" only supports "inline" cache mode and does
        // *not* support multi-arch builds.
        private val Project.isleBuilderDriver: String
            get() = properties.getOrDefault("isle.build.driver", "docker") as String

        private val Project.isDefaultDriver: Boolean
            get() = isleBuilderDriver == "docker"

        private val Project.isContainerDriver: Boolean
            get() = isleBuilderDriver == "docker-container"

        // Not yet supported.
        private val Project.isKubernetesDriver: Boolean
            get() = isleBuilderDriver == "kubernetes"

        // The name of the builder
        val Project.isleBuilder: String
            get() = properties.getOrDefault("isle.build.driver.docker-container.name", "isle-buildkit") as String

        // The image to use for the "docker-container" builder.
        val Project.isleBuilderImage: String
            get() = properties.getOrDefault(
                "isle.build.driver.docker-container.image",
                "moby/buildkit:v0.11.1"
            ) as String

        // Only applies to linux hosts, Docker Desktop comes bundled with Qemu.
        // Allows us to build cross-platform images by emulating the target platform.
        val Project.isleBuilderQemuImage: String
            get() = properties.getOrDefault("isle.build.qemu.image", "tonistiigi/binfmt:qemu-v7.0.0-28") as String

        // The registry to use when building/pushing images.
        val Project.isleBuildRegistry: String
            get() = properties.getOrDefault("isle.build.registry", "islandora") as String

        private val Project.isleBuildRegistryIsLocal: Boolean
            get() = isleBuildRegistry == isleLocalRegistryDomain

        // The target(s) or group(s) to build from the docker-bake.hcl file.
        val Project.isleBuildTargets: Set<String>
            get() = (properties.getOrDefault("isle.build.targets", "default") as String)
                .split(',')
                .map { it.trim().normalizeDockerTag() }
                .filter { it.isNotEmpty() }
                .toSet()

        // The tag to use when building/pushing images.
        val Project.isleBuildTags: Set<String>
            get() {
                val default = if (tag.matches("""[0-9]+\.[0-9]+\.[0-9]+""".toRegex())) {
                    val tags = mutableListOf(tag)
                    val components = tag.split(".")
                    val major = components[0]
                    val minor = components[1]
                    tags.add("$major.$minor")
                    tags.add(major)
                    if (isLatestTag) {
                        tags.add("latest")
                    }
                    tags.joinToString(",")
                } else {
                    branch
                }
                return (properties.getOrDefault("isle.build.tags", "") as String).ifBlank {
                    default
                }.split(',')
                    .map { it.trim().normalizeDockerTag() }
                    .filter { it.isNotEmpty() }
                    .toSet()
            }

        // The tag to use when building/pushing images.
        val Project.isleBuildTagsAddArchSuffix: Boolean
            get() {
                return if (isleBuildPlatforms.count() > 1) {
                    true
                } else {
                    (properties.getOrDefault("isle.build.tags.add.arch.suffix", "false") as String).toBoolean()
                }
            }

        // Push to remote cache when building (requires authentication).
        private val Project.isleBuildPushToRemoteCache: Boolean
            get() = (properties.getOrDefault("isle.build.push.to.remote.cache", "false") as String).toBoolean()

        // Load images after building, if not specified images will be pulled instead by tasks that require them.
        val Project.isleBuildLoad: Boolean
            get() = (properties.getOrDefault("isle.build.load", "true") as String).toBoolean()

        // Push images after building (required when using "docker-container" driver).
        val Project.isleBuildPush: Boolean
            get() = (properties.getOrDefault("isle.build.push", "false") as String).toBoolean()

        // The platform to build image(s) for, If unspecified it will target the
        // host platform.
        val Project.isleBuildPlatforms: Set<String>
            get() {
                val arch = DefaultNativePlatform.getCurrentArchitecture()!!
                val platform = if (arch.isAmd64) "linux/amd64" else "linux/arm64"
                return (properties.getOrDefault("isle.build.platforms", "") as String).ifEmpty {
                    platform
                }.split(',')
                    .filter { it.isNotEmpty() }
                    .toSet()
            }

        // Should match String.platformTaskSuffix output.
        val Project.isleHostArchBuildTask: TaskProvider<Bake>
            get() = DefaultNativePlatform.getCurrentArchitecture()!!.let { arch ->
                val name = if (arch.isAmd64) "Amd64" else "Arm64"
                tasks.named<Bake>("build$name")
            }

        // Helper for generating task names with a platform suffix.
        // We only build linux images so strip that from the start.
        val String.platformTaskSuffix: String
            get() = removePrefix("linux/").replaceFirstChar(Char::titlecase)
    }

    // https://github.com/moby/buildkit/blob/v0.10.6/docs/buildkitd.toml.md
    @CacheableTask
    open class BuilderConfiguration : DefaultTask() {
        @Input
        val registry = project.objects.property<String>()

        @InputFile
        @PathSensitive(PathSensitivity.RELATIVE)
        val cert = project.objects.fileProperty()

        @InputFile
        @PathSensitive(PathSensitivity.RELATIVE)
        val key = project.objects.fileProperty()

        @InputFile
        @PathSensitive(PathSensitivity.RELATIVE)
        val rootCA = project.objects.fileProperty()

        @OutputFile
        val config =
            project.objects.fileProperty().convention(project.layout.buildDirectory.map { it.file("buildkitd.toml") })

        init {
            logging.captureStandardOutput(INFO)
        }

        @TaskAction
        fun exec() {
            // GitHub Actions has limited disk space, so we must clean up as we go.
            // Additionally, when using CI we do not push to the local registry, but use a remote instead.
            // Keep only up to 8GB of storage.
            if (System.getenv("GITHUB_ACTIONS") == "true") {
                config.get().asFile.writeText(
                    """
                    [worker.containerd]
                      enabled = false
                    [worker.oci]
                      enabled = true
                      gc = true
                      gckeepstorage = 8000
                """.trimIndent()
                )
            } else {
                // Locally developers can run prune when needed, disable GC for speed!!!
                // Also, a local registry is required to push / pull form, unless you have suitable remote setup.
                config.get().asFile.writeText(
                    """
                    [worker.containerd]
                      enabled = false
                    [worker.oci]
                      enabled = true
                      gc = false
                    [registry."${registry.get()}"]
                      insecure=false
                      ca=["${rootCA.get().asFile.absolutePath}"]
                      [[registry."${registry.get()}".keypair]]
                        key="${key.get().asFile.absolutePath}"
                        cert="${cert.get().asFile.absolutePath}"
                """.trimIndent()
                )
            }
        }
    }

    abstract class AbstractBuilder : DefaultTask() {
        @Input
        val name = project.objects.property<String>()

        private val inspect = project.objects.property<Pair<Boolean, Boolean>>().convention(
            project.provider {
                // Make sure output is empty in-case execution fails, as we do not want to use a value from a previous run.
                ByteArrayOutputStream().use { output ->
                    val exists = project.exec {
                        commandLine(
                            "docker",
                            "buildx",
                            "inspect",
                            "--builder", name.get()
                        )
                        standardOutput = output
                        errorOutput = nullOutputStream()
                        isIgnoreExitValue = true
                    }.exitValue == 0
                    val running = output.toString().lines().any { it.matches("""Status:\s+running""".toRegex()) }
                    Pair(exists, running)
                }
            }
        )

        @get:Internal
        protected val exists: Boolean
            get() = inspect.get().first

        @get:Internal
        protected val running: Boolean
            get() = inspect.get().second

        init {
            logging.captureStandardOutput(INFO)
            logging.captureStandardError(INFO)
        }
    }

    open class CreateBuilder : AbstractBuilder() {
        @InputFile
        @PathSensitive(PathSensitivity.RELATIVE)
        val config = project.objects.fileProperty()

        @Input
        val network = project.objects.property<String>()

        @Input
        val image = project.objects.property<String>().convention(project.isleBuilderImage)

        @InputFile
        @PathSensitive(PathSensitivity.RELATIVE)
        val cert = project.objects.fileProperty()

        @InputFile
        @PathSensitive(PathSensitivity.RELATIVE)
        val key = project.objects.fileProperty()

        @InputFile
        @PathSensitive(PathSensitivity.RELATIVE)
        val rootCA = project.objects.fileProperty()

        init {
            @Suppress("LeakingThis") onlyIf {
                !exists && project.isContainerDriver
            }
        }

        @TaskAction
        fun create() {
            project.exec {
                commandLine(
                    "docker",
                    "buildx",
                    "create",
                    "--bootstrap",
                    "--config", config.get().asFile.absolutePath,
                    "--driver-opt",
                    "image=${image.get()},network=${network.get()}",
                    "--name",
                    name.get()
                )
            }
        }
    }

    open class DestroyBuilder : AbstractBuilder() {

        init {
            @Suppress("LeakingThis") onlyIf {
                exists
            }
        }

        @TaskAction
        fun create() {
            project.exec {
                commandLine("docker", "buildx", "rm", name.get())
            }
        }
    }

    open class StopBuilder : AbstractBuilder() {

        init {
            @Suppress("LeakingThis") onlyIf {
                exists && running
            }
        }

        @TaskAction
        fun create() {
            project.exec {
                commandLine("docker", "buildx", "stop", name.get())
            }
        }
    }

    open class StartBuilder : AbstractBuilder() {

        init {
            @Suppress("LeakingThis") onlyIf {
                exists && !running
            }
        }

        @TaskAction
        fun create() {
            project.exec {
                commandLine("docker", "buildx", "inspect", name.get(), "--bootstrap")
            }
        }
    }

    open class BuilderDiskUsage : AbstractBuilder() {
        init {
            // Works with both docker driver as well so change the default name.
            if (project.isDefaultDriver) {
                name.convention("default")
            }
            // Display at a higher level so the user can see without --info.
            logging.captureStandardOutput(QUIET)
            logging.captureStandardError(ERROR)
            @Suppress("LeakingThis") onlyIf {
                exists && running
            }
        }

        @TaskAction
        fun create() {
            project.exec {
                commandLine("docker", "buildx", "du", "--builder", name.get())
            }
        }
    }

    open class PruneBuildCache : AbstractBuilder() {

        init {
            // Works with both docker driver as well so change the default name.
            if (project.isDefaultDriver) {
                name.convention("default")
            }
            @Suppress("LeakingThis") onlyIf {
                exists && running
            }
        }

        @TaskAction
        fun create() {
            project.exec {
                commandLine("docker", "buildx", "prune", "--builder", name.get(), "--force")
            }
        }
    }

    open class Bake : DefaultTask() {
        @Input
        val builder = project.objects.property<String>()

        @InputFile
        @PathSensitive(PathSensitivity.RELATIVE)
        val bakefile = project.objects.fileProperty()
            .convention(project.rootProject.layout.projectDirectory.file("docker-bake.hcl"))

        @Input
        val image = project.objects.property<String>()

        @Input
        val target = project.objects.property<String>()

        @InputFiles
        @PathSensitive(PathSensitivity.RELATIVE)
        val context = project.fileTree(".") {
            // Exclude files excluded by Docker.
            include("**")
            val ignore = project.projectDir.resolve(".dockerignore")
            if (ignore.exists()) {
                exclude(ignore.readLines().map { it })
            }
        }

        @Input
        val platform = project.objects.property<String>()

        @Input
        val arch = platform.map { it.removePrefix("linux/") }

        @Input
        val registry = project.objects.property<String>().convention(project.isleBuildRegistry)

        @Input
        val tags = project.objects.setProperty<String>().convention(project.isleBuildTags)

        // Map of manifest image name to its component parts.
        // Only applicable when producing images with arch suffix.
        @get:Internal
        val manifests: Map<String, Set<String>>
            get() = project.isleBuildTags.associate { tag ->
                val image = "${registry.get()}/${image.get()}"
                Pair("${image}:${tag}", setOf("${image}:${tag}-${arch.get()}"))
            }

        @Input
        val load = project.objects.property<Boolean>().convention(project.isleBuildLoad)

        @Input
        val push = project.objects.property<Boolean>().convention(project.isleBuildPush)

        @Input
        protected val arguments = project.provider {
            mutableListOf(
                "docker",
                "buildx",
                "bake",
                "-f",
                bakefile.get().asFile.absolutePath,
                "--builder",
                builder.get(),
                "--metadata-file",
                metadata.get().asFile.absolutePath
            ).apply {
                if (load.get()) {
                    add("--set=${target.get()}.output=type=docker")
                }
                if (push.get()) {
                    add("--set=${target.get()}.output=type=registry")
                }
                // Targets to build (load or push)
                add(target.get())
            }
        }

        @Input
        protected val environment = project.provider {
            mapOf(
                // Doesn't have an effect on versions of Buildkit prior to 0.11.1
                "SOURCE_DATE_EPOCH" to project.sourceDateEpoch,
                "REPOSITORY" to registry.get(),
                "TAGS" to tags.get().joinToString(","),
                "BRANCH" to project.branch,
                "HOST_ARCH" to arch.get(),
            )
        }

        @OutputFile
        val metadata: RegularFileProperty =
            project.objects.fileProperty()
                .convention(arch.flatMap { project.layout.buildDirectory.file("build.${it}.json") })

        // Used for inputs into other tasks.
        @Internal
        val digest = metadata.map { file ->
            val json = file.asFile.readText()
            val node: JsonNode = ObjectMapper().readTree(json)
            // The default builder is the only builder capable of loading and pulling, use the loaded digested as this
            // is used for test inputs.
            val field = if (builder.get() == "default" && push.get())
                "containerimage.config.digest"
            else if (builder.get() != "default" && load.get())
                "containerimage.config.digest"
            else
                "containerimage.digest"
            node.get(image.get())!!.get(field)!!.asText().trim()
        }

        init {
            logging.captureStandardOutput(INFO)
            logging.captureStandardError(INFO)
        }

        @TaskAction
        fun build() {
            project.exec {
                workingDir(bakefile.get().asFile.parentFile.absolutePath)
                environment(this@Bake.environment.get())
                commandLine(this@Bake.arguments.get())
            }
        }
    }

    abstract class BuildKit : BuildService<BuildServiceParameters.None>, AutoCloseable {}

    override fun apply(pluginProject: Project): Unit = pluginProject.run {
        apply<SharedPropertiesPlugin>()
        apply<DockerPlugin>()
        apply<CertificateGenerationPlugin>()
        apply<RegistryPlugin>()

        val generateCertificates = tasks.named<CertificateGenerationPlugin.GenerateCerts>("generateCertificates")
        val createRegistry = tasks.named<RegistryPlugin.CreateRegistry>("createRegistry")
        val startRegistry = tasks.named<DockerContainer.DockerStartContainer>("startRegistry")
        val login = tasks.named<Exec>("login")
        val destroyRegistryNetwork = tasks.named<DockerNetwork.DockerRemoveNetwork>("destroyRegistryNetwork")

        val installBinFmt by tasks.registering(Exec::class) {
            group = "Isle Build"
            description = "Install https://github.com/tonistiigi/binfmt to enable multi-arch builds on Linux."
            commandLine = listOf(
                "docker",
                "container",
                "run",
                "--rm",
                "--privileged",
                isleBuilderQemuImage,
                "--install", "all"
            )
            // Cross building with Qemu is already installed with Docker Desktop, so we only need to install on Linux.
            // Additionally, it does not work with non x86_64 hosts.
            onlyIf {
                val os = DefaultNativePlatform.getCurrentOperatingSystem()!!
                val arch = DefaultNativePlatform.getCurrentArchitecture()!!
                os.isLinux && arch.isAmd64
            }
        }

        val createBuilderConfiguration by tasks.registering(BuilderConfiguration::class) {
            group = "Isle Build"
            description = "Generate buildkitd.toml.md to configure buildkit."
            registry.set(createRegistry.map { it.registry })
            cert.set(generateCertificates.flatMap { it.cert })
            key.set(generateCertificates.flatMap { it.key })
            rootCA.set(generateCertificates.flatMap { it.rootCA })
        }

        val stopBuilders by tasks.registering {
            group = "Isle Build"
            description = "Stops the builder(s) container(s) if running"
        }

        val destroyBuilders by tasks.registering {
            group = "Isle Build"
            description = "Destroys the builders(s) container(s) if they exist"
        }

        destroyRegistryNetwork.configure {
            dependsOn(destroyBuilders) // Cannot remove networks of active containers as they share the same network.
        }

        val createBuilders by tasks.registering {
            group = "Isle Build"
            description = "Creates the builders(s) containers(s) if 'docker-container' driver if chosen"
        }

        val startBuilders by tasks.registering {
            group = "Isle Build"
            description = "Starts the builders(s) containers(s) if `docker-container' driver if chosen"
        }

        val pruneBuildCaches by tasks.registering {
            group = "Isle Build"
            description = "Prunes build cache(s) of the chosen driver."
        }

        val builders = isleBuildPlatforms.associateWith { buildPlatform ->
            val suffix = buildPlatform.platformTaskSuffix
            val builderName = "${project.isleBuilder}-${suffix.replaceFirstChar(Char::lowercase)}"

            val stopBuilder by tasks.register<StopBuilder>("stopBuilder${suffix}") {
                group = "Isle Build"
                description = "Stops the builder a container if running"
                name.set(builderName)
            }

            stopBuilders.configure {
                dependsOn(stopBuilder)
            }

            val destroyBuilder by tasks.register<DestroyBuilder>("destroyBuilder${suffix}") {
                group = "Isle Build"
                description = "Creates a container for the buildkit daemon"
                name.set(builderName)
                dependsOn(stopBuilder)
            }

            destroyBuilders.configure {
                dependsOn(destroyBuilder)
            }

            val createBuilder by tasks.register<CreateBuilder>("createBuilder${suffix}") {
                group = "Isle Build"
                description = "Creates the 'docker-container' driver if applicable"
                name.set(builderName)
                config.set(createBuilderConfiguration.flatMap { it.config })
                image.set(isleBuilderImage)
                network.set(createRegistry.map { it.network.get() })
                cert.set(generateCertificates.flatMap { it.cert })
                key.set(generateCertificates.flatMap { it.key })
                rootCA.set(generateCertificates.flatMap { it.rootCA })
                dependsOn(installBinFmt, startRegistry)
                mustRunAfter(destroyBuilder)
            }

            createBuilders.configure {
                dependsOn(createBuilder)
            }

            val startBuilder by tasks.register<StartBuilder>("startBuilder${suffix}") {
                group = "Isle Build"
                description = "Starts the `docker-container builder if applicable"
                name.set(builderName)
                dependsOn(createBuilder)
            }

            startBuilders.configure {
                dependsOn(startBuilder)
            }

            val pruneBuildCache by tasks.register<PruneBuildCache>("pruneBuildCache${suffix}") {
                group = "Isle Build"
                description = "Prunes build cache of the driver."
                name.set(builderName)
            }

            pruneBuildCaches.configure {
                dependsOn(pruneBuildCache)
            }

            tasks.register<BuilderDiskUsage>("displayBuilderDiskUsage${suffix}") {
                group = "Isle Build"
                description = "Displays disk usage information for the docker-container builder."
                name.set(builderName)
            }

            createBuilder
        }

        // Buildkit does not handle multiple requests well so force them to run serially.
        val buildkitServices = isleBuildPlatforms.associateWith { buildPlatform ->
            gradle.sharedServices.registerIfAbsent(
                "buildkit${buildPlatform.platformTaskSuffix}",
                BuildKit::class.java
            ) {
                maxParallelUsages.set(1)
            }
        }

        // Create a build task in each Docker project, per arch build tasks will add dependencies to it later.
        subprojects {
            if (isDockerProject) {
                val build by tasks.registering {
                    group = "Isle Build"
                    description = "Build ${project.name} docker image(s) for each platform"
                }

                val requiredImages = ByteArrayOutputStream().use { output ->
                    project.exec {
                        commandLine = listOf("docker", "buildx", "bake", "--print", project.name)
                        workingDir(rootProject.projectDir)
                        standardOutput = output
                        errorOutput = nullOutputStream()
                    }
                    BakeOptionsFile.deserialize(output.toString()).target
                }

                val buildTasks = isleBuildPlatforms.map { buildPlatform ->
                    val suffix = buildPlatform.platformTaskSuffix
                    val buildSpecificArchitecture by tasks.register<Bake>("build${suffix}") {
                        group = "Isle Build"
                        description = "Build ${this@subprojects.name} ($buildPlatform) docker image"
                        image.set(project.name)
                        target.set(arch.map {
                            if (isleBuildTagsAddArchSuffix && isleBuildPushToRemoteCache) {
                                "${project.name}-${it}-ci"
                            }
                            else if (isleBuildTagsAddArchSuffix) {
                                "${project.name}-${it}"
                            }
                            else {
                                project.name
                            }
                        })
                        platform.set(buildPlatform)
                        // Works with both docker driver as well so change the default name.
                        if (project.isDefaultDriver) {
                            builder.set("default")
                        } else {
                            builder.set(builders[buildPlatform]!!.name)
                        }
                        // Start builder before building.
                        dependsOn(login, ":startBuilder${suffix}")
                        // Build dependent projects before building this one.
                        dependsOn(requiredImages
                            .filterNot { (image, _) -> image == project.name }
                            .map { (image, _) -> ":${image}:build${suffix}" })
                        // Limit concurrency in requests to buildkit to prevent crashes.
                        usesService(buildkitServices[buildPlatform]!!)
                    }

                    build.configure {
                        dependsOn(buildSpecificArchitecture)
                    }

                    buildSpecificArchitecture
                }

                tasks.register("manifest") {
                    group = "Isle Build"
                    description = "Creates a multi-platform manifest"
                    onlyIf {
                        project.isleBuildTagsAddArchSuffix // Manifests only apply to multi-arch images.
                    }
                    doFirst {
                        val manifests = buildTasks.fold(mapOf<String, Set<String>>()) { acc, task ->
                            (task.manifests.asSequence() + acc.asSequence())
                                .distinct()
                                .groupBy({ it.key }, { it.value })
                                .mapValues { (_, b) -> b.flatten().toSet() }
                        }
                        manifests.forEach { (manifest, targets) ->
                            val commandLineArguments = mutableListOf<String>()
                            if (isleBuildRegistryIsLocal) {
                                commandLineArguments.addAll(
                                    listOf(
                                        "docker",
                                        "exec",
                                        createRegistry.get().name.get()
                                    )
                                )
                            }
                            commandLineArguments.addAll(
                                listOf(
                                    "docker",
                                    "buildx",
                                    "imagetools",
                                    "create",
                                    "-t",
                                    manifest
                                ) + targets
                            )
                            project.exec {
                                // If using the local registry execute in the registry container so the domain name matches.
                                commandLine = commandLineArguments
                                workingDir = projectDir
                            }
                        }
                    }
                    dependsOn(login, startRegistry)
                    mustRunAfter(build)
                }
            }
        }
    }

    data class BakeOptionsTargetProperties(val context: String, val tags: List<String>) : Serializable
    data class BakeOptionsFile(val target: Map<String, BakeOptionsTargetProperties>) : Serializable {
        companion object {
            fun deserialize(file: File): BakeOptionsFile =
                ObjectMapper(YAMLFactory())
                    .registerModule(KotlinModule.Builder().build())
                    .configure(JsonParser.Feature.ALLOW_UNQUOTED_FIELD_NAMES, true)
                    .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
                    .readValue(file)

            fun deserialize(contents: String): BakeOptionsFile =
                ObjectMapper(YAMLFactory())
                    .registerModule(KotlinModule.Builder().build())
                    .configure(JsonParser.Feature.ALLOW_UNQUOTED_FIELD_NAMES, true)
                    .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
                    .readValue(contents)
        }
    }
}
