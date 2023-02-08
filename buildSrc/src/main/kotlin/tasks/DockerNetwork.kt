package tasks

import org.apache.commons.io.output.NullOutputStream
import org.gradle.api.DefaultTask
import org.gradle.api.logging.LogLevel
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.Internal
import org.gradle.api.tasks.TaskAction
import org.gradle.kotlin.dsl.property

@Suppress("unused")
class DockerNetwork {

    abstract class AbstractDockerNetwork : DefaultTask() {
        @Input
        val network = project.objects.property<String>()

        @Internal
        val baseArguments = listOf("docker", "network")

        protected fun exists() = project.exec {
            commandLine(baseArguments + listOf("inspect", network.get()))
            standardOutput = NullOutputStream()
            errorOutput = NullOutputStream()
            isIgnoreExitValue = true
        }.exitValue == 0

        init {
            logging.captureStandardOutput(LogLevel.INFO)
            logging.captureStandardError(LogLevel.INFO)
        }
    }

    open class DockerCreateNetwork : AbstractDockerNetwork() {

        init {
            @Suppress("LeakingThis")
            onlyIf {
                !exists()
            }
        }

        @TaskAction
        fun create() {
            project.exec {
                commandLine = baseArguments + listOf("create", network.get())
            }
        }
    }

    open class DockerRemoveNetwork : AbstractDockerNetwork() {
        init {
            @Suppress("LeakingThis")
            onlyIf {
                exists()
            }
        }

        @TaskAction
        fun remove() {
            project.exec {
                commandLine = baseArguments + listOf("rm", network.get())
            }
        }
    }
}