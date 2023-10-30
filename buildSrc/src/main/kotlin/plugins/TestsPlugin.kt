package plugins

import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.databind.DeserializationFeature
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import com.fasterxml.jackson.module.kotlin.KotlinModule
import com.fasterxml.jackson.module.kotlin.readValue
import org.gradle.api.DefaultTask
import org.gradle.api.GradleException
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.tasks.*
import org.gradle.kotlin.dsl.*
import plugins.IslePlugin.Companion.isDockerProject
import plugins.SharedPropertiesPlugin.Companion.isleRepository
import plugins.SharedPropertiesPlugin.Companion.isleTag
import java.io.ByteArrayOutputStream
import java.io.File
import java.time.Duration
import java.util.concurrent.CompletableFuture
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit


// Generate reports via Syft and Grype.
@Suppress("unused")
class TestsPlugin : Plugin<Project> {

    companion object {
        // Check if the project should have docker related tasks.
        val Project.isDockerComposeProject: Boolean
            get() = projectDir.resolve("docker-compose.yml").exists()

        // Pushing may require logging in to the repository, if so these need to be populated.
        // The local registry does not require credentials.
        val Project.isleTestPull: Boolean
            get() = (properties.getOrDefault("isle.test.pull", "false") as String).toBoolean()
    }


    open class DockerCompose : DefaultTask() {
        data class DockerComposeFile(val services: Map<String, Service>) {
            companion object {
                fun deserialize(file: File): DockerComposeFile =
                    ObjectMapper(YAMLFactory())
                        .registerModule(KotlinModule.Builder().build())
                        .configure(JsonParser.Feature.ALLOW_UNQUOTED_FIELD_NAMES, true)
                        .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
                        .readValue(file)
            }
        }

        data class Service(val image: String) {
            companion object {
                @Suppress("RegExpRedundantEscape")
                val regex = """\$\{(?<variable>[^:]+):-(?<default>.+)\}""".toRegex()
            }

            private fun variable() = regex
                .matchEntire(image)
                ?.groups
                ?.get("variable")
                ?.value

            fun env(image: String) =
                variable()
                    ?.let { variable ->
                        variable to image
                    }
        }

        @Internal
        val baseArguments = listOf(
            "docker",
            "compose"
        )

        @Input
        val environment = project.objects.mapProperty<String, String>().convention(project.provider {
            val images = project.rootProject.allprojects.filter { it.isDockerProject }.map { it.name }
            images.associate { image ->
                image.uppercase().replace("-", "_") to (project.properties.getOrDefault(
                    "isle.${image}.digest",
                    ""
                ) as String).ifEmpty { "${project.isleRepository}/${image}:${project.isleTag}" }
            }.plus(Pair("HOME", System.getenv("HOME")))
        })

        @get:Internal
        val dockerCompose by lazy {
            DockerComposeFile.deserialize(project.file("docker-compose.yml"))
        }

        // Any file might be referenced by the docker-compose.yml file / as a volume, etc.
        @InputDirectory
        @PathSensitive(PathSensitivity.RELATIVE)
        val context = project.objects.directoryProperty().convention(project.layout.projectDirectory)
    }

    @CacheableTask
    open class DockerComposeUp : DockerCompose() {

        companion object {
            val pool: ExecutorService = Executors.newCachedThreadPool()
        }

        @Input
        val exitCodeConditions = project.objects.mapProperty<String, Set<Int>>()

        @Input
        val outputConditions = project.objects.mapProperty<String, String>()

        // Capture the log output after exit (sometimes has more text).
        @OutputDirectory
        val logs = project.objects.directoryProperty().convention(project.layout.buildDirectory)

        init {
            // By default, limit max execution time to 5 minutes.
            timeout.convention(Duration.ofMinutes(5))

            // Expect each container exits 0 by default.
            exitCodeConditions.putAll(dockerCompose.services.mapValues { setOf(0) })
        }

        // Gets the identifiers of all the services created by the docker compose file.
        private val containers by lazy {
            ByteArrayOutputStream().use { output ->
                project.exec {
                    workingDir(project.projectDir)
                    commandLine(baseArguments + listOf("ps", "-aq"))
                    standardOutput = output
                }
                output
                    .toString()
                    .lines()
                    .filter { it.isNotBlank() }
            }
        }

        // Performs an `docker inspect` on all the services created by the docker compose file.
        // Builds a map of service names paired with their exit codes.
        @get:Internal
        protected val exitCodes by lazy {
            containers.associate { container ->
                ByteArrayOutputStream().use { output ->
                    project.exec {
                        workingDir(project.projectDir)
                        commandLine("docker", "inspect", container)
                        standardOutput = output
                    }
                    output.toString()
                }.let {
                    val node: JsonNode = ObjectMapper().readTree(it)
                    val service =
                        node.get(0)!!.get("Config")!!.get("Labels")!!.get("com.docker.compose.service")!!.asText()!!
                    val exitCode = node.get(0)!!.get("State")!!.get("ExitCode")!!.asInt()
                    Pair(service, exitCode)
                }
            }
        }

        // Helper for writing tests which need to look for specific exit codes.
        fun expectOutput(service: String, output: String) {
            outputConditions.put(service, output)
        }

        // Helper for writing tests which need to look for specific exit codes.
        fun expectExitCode(service: String, exitCode: Int) {
            val map = exitCodeConditions.get().toMutableMap()
            map[service] = setOf(exitCode)
            exitCodeConditions.set(map)
        }

        // Helper for writing tests which need to look for specific exit codes.
        fun expectExitCodes(service: String, vararg exitCodes: Int) {
            val map = exitCodeConditions.get().toMutableMap()
            map[service] = exitCodes.toSet()
            exitCodeConditions.set(map)
        }

        // Monitor output of the given service.
        private fun monitorService(service: String, output: String): Triple<String, String, Boolean> {
            logger.info("""Looking for "$output" in $service logs""")
            val reader = CompletableFuture.supplyAsync({
                val start = System.nanoTime()
                while ((System.nanoTime() - start) <= timeout.get().toNanos()) {
                    ByteArrayOutputStream().use { outputStream ->
                        project.exec {
                            workingDir = project.projectDir
                            commandLine = baseArguments + listOf("logs", service)
                            standardOutput = outputStream
                        }
                        output.lines()
                    }.forEach { line ->
                        if (line.contains(output)) {
                            logger.info("""Found "$output" in $service logs""")
                            return@supplyAsync Triple(service, output, true)
                        }
                    }
                }
                logger.info("""Missing "$output" from $service logs""")
                return@supplyAsync Triple(service, output, false)
            }, pool)
            return reader.get()
        }

        @TaskAction
        fun up() {
            val up = CompletableFuture.supplyAsync(
                {
                    val process = ProcessBuilder().run {
                        directory(project.projectDir)
                        command(baseArguments + listOf("up", "--abort-on-container-exit"))
                        redirectOutput(logs.get().asFile.resolve("up.log"))
                        redirectErrorStream(true)
                        environment().putAll(this@DockerComposeUp.environment.get())
                        start()
                    }
                    if (!process.waitFor(timeout.get().toMillis(), TimeUnit.MILLISECONDS)) {
                        process.destroyForcibly()
                    }
                    process.exitValue()
                }, pool
            )

            // Used to fail the task if any condition was not met.
            var failedConditions = false

            if (outputConditions.get().isNotEmpty()) {
                Thread.sleep(5000)
                val logMonitors = outputConditions.get().map { (service, output) ->
                    CompletableFuture.supplyAsync({
                        monitorService(service, output)
                    }, pool)
                }.toTypedArray()
                // Will block until found, or timeout.
                CompletableFuture.allOf(*logMonitors).join()
                // Exit ignoring the exit code for docker-compose as we look at each container instead.
                up.complete(0)
                // Check for any monitors that failed to find their expected output.
                failedConditions = logMonitors.any { !it.get().third }
            }
            up.join() // Either ended of its own accord or output conditions have all been satisfied.
            // Wait for all containers to come down before we check their exit codes.
            project.exec {
                workingDir = project.projectDir
                commandLine = baseArguments + listOf("stop")
            }
            exitCodes.forEach { (service, _) ->
                ProcessBuilder().run {
                    directory(project.projectDir)
                    command(baseArguments + listOf("logs", service))
                    redirectOutput(logs.get().asFile.resolve("${service}.log"))
                    redirectErrorStream(true)
                    start()
                }.waitFor()
            }
            exitCodeConditions.get().forEach { (service, expectedExitCodes) ->
                val exitCode = exitCodes[service]
                logger.info("Service ($service) exited with: $exitCode, expected ${expectedExitCodes.joinToString(", ")}")
                if (!expectedExitCodes.contains(exitCode)) {
                    failedConditions = true
                }
            }
            if (failedConditions) {
                logger.info("Failed Conditions")
                throw GradleException("Failed conditions")
            }
        }
    }

    open class DockerComposeDown : DockerCompose() {

        @TaskAction
        fun down() {
            project.exec {
                workingDir(project.projectDir)
                commandLine(baseArguments + listOf("down", "-v"))
            }
        }
    }

    override fun apply(pluginProject: Project): Unit = pluginProject.run {
        apply<SharedPropertiesPlugin>()

        allprojects {
            // Auto-apply plugins to relevant projects in the "tests" folder of docker projects.
            if (isDockerProject) {
                subprojects {
                    if (isDockerComposeProject) {
                        val cleanUpBefore by tasks.registering(DockerComposeDown::class) {
                            group = "Isle Tests"
                            description = "Clean up resources before running test (if interrupted externally, etc)"
                        }

                        // Placeholder which can be overridden in tests.
                        val setUp by tasks.registering(DockerCompose::class) {
                            group = "Isle Tests"
                            description = "Prepare to run test"
                            dependsOn(cleanUpBefore)
                        }

                        tasks.register<DockerComposeDown>("cleanUpAfter") {
                            group = "Isle Tests"
                            description = "Clean up resources after running test"
                        }

                        tasks.register<DockerComposeUp>("test") {
                            group = "Isle Tests"
                            description = "Perform test"
                            dependsOn(setUp)
                            doFirst {
                                if (project.isleTestPull) {
                                    project.exec {
                                        workingDir = project.projectDir
                                        commandLine = baseArguments + listOf("pull", "--ignore-pull-failures")
                                        environment = this@register.environment.get() as Map<String, String>
                                    }
                                }
                            }
                        }
                    }
                }
                tasks.register("test") {
                    description = "Test docker image(s)"
                    dependsOn(project.subprojects.mapNotNull { it.tasks.matching { task -> task.name == "test" } })
                }
            }
        }
    }
}
