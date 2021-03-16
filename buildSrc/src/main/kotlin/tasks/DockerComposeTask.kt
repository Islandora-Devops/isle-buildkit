package tasks

import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.databind.DeserializationFeature
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import com.fasterxml.jackson.module.kotlin.KotlinModule
import com.fasterxml.jackson.module.kotlin.readValue
import com.github.dockerjava.api.command.InspectContainerResponse.ContainerState
import org.gradle.api.file.RegularFileProperty
import org.gradle.api.tasks.*
import org.gradle.kotlin.dsl.listProperty
import org.gradle.kotlin.dsl.mapProperty
import org.gradle.kotlin.dsl.provideDelegate
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.OutputStream
import java.time.Duration

@Suppress("UnstableApiUsage")
abstract class DockerComposeTask : DockerClientTask() {

    data class DockerComposeFile(val services: Map<String, Service>) {
        companion object {
            fun deserialize(file: File): DockerComposeFile = ObjectMapper(YAMLFactory())
                .registerModule(KotlinModule())
                .configure(JsonParser.Feature.ALLOW_UNQUOTED_FIELD_NAMES, true)
                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
                .readValue(file)
        }
    }

    data class Service(val image: String) {
        companion object {
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

    // The docker-compose.yml file to run.
    @InputFile
    @PathSensitive(PathSensitivity.RELATIVE)
    val dockerComposeFile =
        project.objects.fileProperty().convention(project.layout.projectDirectory.file("docker-compose.yml"))

    private val dockerCompose by lazy {
        DockerComposeFile.deserialize(dockerComposeFile.get().asFile)
    }

    // Environment variables which allow us to override the image used by the service.
    private val imageEnvironmentVariables by lazy {
        val repository = project.rootProject.properties["repository"] as String
        val tag = (project.rootProject.properties["tags"] as String)
            .split(' ')
            .filter { it.isNotEmpty() }
            .map { it.trim() }
            .first()
        dockerCompose.services.mapNotNull { (name, service) ->
            val projectExists = project.findProject(":$name") != null
            if (projectExists) service.env("$repository/$name:$tag") else null
        }.toMap<String, String>()
    }

    // Not actually the image digest but rather an approximation that ignores timestamps, etc.
    // So we do not run test unless the image has actually changed.
    @InputFiles
    @PathSensitive(PathSensitivity.RELATIVE)
    val approximateImageDigests = project.objects.listProperty<RegularFileProperty>().convention(project.provider {
        // If the name of a service matches a known image in this build we will set a dependency on it.
        dockerCompose.services.mapNotNull { (name, _) ->
            project.findProject(":$name")
                ?.tasks
                ?.named("digest", ApproximateImageDigestTask::class.java)
                ?.get()
                ?.digest
        }
    })

    // Capture the log output of the command for later inspection.
    @OutputFile
    val log = project.objects.fileProperty().convention(project.layout.buildDirectory.file("${name}.log"))

    // Environment for docker-compose not the actual containers.
    @Input
    val environment = project.objects.mapProperty<String, String>()

    @Internal
    val states = project.objects.mapProperty<String, ContainerState>()

    init {
        // Rerun test if any of the files in the directory of the docker-compose.yml file changes, as likely they are
        // bind mounted or secrets, etc. The could affect the outcome of the test.
        inputs.dir(project.projectDir)
        // By default limit max execution time to a minute.
        timeout.convention(Duration.ofMinutes(5))
        // Ensure we do not leave container running if something goes wrong.
        project.gradle.buildFinished {
            ByteArrayOutputStream().use { output ->
                invoke("down", "-v", output = output, error = output)
                logger.info(output.toString())
            }
        }
    }

    fun invoke(
        vararg args: String,
        env: Map<String, String> = imageEnvironmentVariables.plus(environment.get()),
        ignoreExitValue: Boolean = false,
        output: OutputStream? = null,
        error: OutputStream? = null
    ) = project.exec {
        environment.putAll(env)
        workingDir = dockerComposeFile.get().asFile.parentFile
        isIgnoreExitValue = ignoreExitValue
        if (output != null) standardOutput = output
        if (error != null) errorOutput = error
        commandLine("docker-compose", "--project-name", project.path.replace(":", "_"), *args)
    }

    fun up(vararg args: String, ignoreExitValue: Boolean = false) = try {
        invoke("up", *args, ignoreExitValue = ignoreExitValue)
    } catch (e: Exception) {
        log()
        throw e
    }

    fun exec(vararg args: String) = invoke("exec", *args)

    private fun stop(vararg args: String) = invoke("stop", *args)

    private fun down(vararg args: String) = invoke("down", *args)

    private fun pull() = dockerCompose.services.keys.mapNotNull { name ->
        // Find services that do not match any projects and pull them as they must refer to an external image.
        // Other images will be provided by dependency on the image digests.
        if (project.rootProject.findProject(":$name") == null) name else null
    }.let { services ->
        if (services.isNotEmpty()) {
            invoke("pull", *services.toTypedArray())
        }
    }

    private fun log() {
        log.get().asFile.outputStream().buffered().use { writer ->
            invoke("logs", "--no-color", "--timestamps", output = writer, error = writer)
        }
    }

    private fun inspect() = ByteArrayOutputStream().use { output ->
        invoke("ps", "-aq", output = output)
        output
            .toString()
            .lines()
            .filter { it.isNotEmpty() }
            .map { container ->
                dockerClient.inspectContainerCmd(container).exec()
            }
    }

    fun setUp() {
        pull()
    }

    fun tearDown() {
        stop()
        states.set(inspect().map { it.config.labels["com.docker.compose.service"]!! to it.state }.toMap())
        log()
        down("-v")
    }
}