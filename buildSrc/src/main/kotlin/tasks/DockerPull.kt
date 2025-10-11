package tasks

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import org.apache.commons.io.output.ByteArrayOutputStream
import org.apache.commons.io.output.NullOutputStream
import org.gradle.api.DefaultTask
import org.gradle.api.logging.LogLevel
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.Internal
import org.gradle.api.tasks.OutputFile
import org.gradle.api.tasks.TaskAction
import org.gradle.kotlin.dsl.property
import org.gradle.process.ExecOperations
import javax.inject.Inject

// Pulls down a docker image if not already present.
// https://docs.docker.com/engine/reference/commandline/pull
abstract class DockerPull : DefaultTask() {
    @get:Inject
    abstract val execOperations: ExecOperations

    @Input
    val image = project.objects.property<String>()

    @OutputFile
    val digestFile = project.objects.fileProperty().convention(image.flatMap {
        project.layout.buildDirectory.file(it.replace(Regex("""[:/]"""), ".") + ".digest")
    })

    @get:Internal
    val digest: String
        get() = digestFile.get().asFile.readText().trim()

    private fun exists() = digestFile.get().asFile.let { file ->
        file.exists() && file.readText().trim().let { digest ->
            execOperations.exec {
                commandLine("docker", "inspect", digest)
                standardOutput = NullOutputStream()
                errorOutput = NullOutputStream()
                isIgnoreExitValue = true
            }.exitValue == 0
        }
    }

    init {
        logging.captureStandardOutput(LogLevel.INFO)
        logging.captureStandardError(LogLevel.INFO)

        outputs.upToDateWhen {
            exists()
        }
    }

    @TaskAction
    fun pull() {
        execOperations.exec {
            commandLine = listOf("docker", "pull", image.get())
        }
        ByteArrayOutputStream().use { output ->
            execOperations.exec {
                commandLine = listOf("docker", "inspect", image.get())
                standardOutput = output
            }
            output.toString()
        }.let { output ->
            val node: JsonNode = ObjectMapper().readTree(output)
            val content = node.first().get("RepoDigests").first().asText().trim()
            digestFile.get().asFile.writeText(content)
        }
    }
}
