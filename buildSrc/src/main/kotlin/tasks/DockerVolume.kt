package tasks

import org.apache.commons.io.output.NullOutputStream
import org.gradle.api.DefaultTask
import org.gradle.api.logging.LogLevel
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.TaskAction
import org.gradle.kotlin.dsl.property

@Suppress("unused")
class DockerVolume {

    abstract class AbstractDockerVolume : DefaultTask() {
        @Input
        val volume = project.objects.property<String>()

        protected fun exists() = project.exec {
            commandLine("docker", "volume", "inspect", volume.get())
            standardOutput = NullOutputStream()
            errorOutput = NullOutputStream()
            isIgnoreExitValue = true
        }.exitValue == 0

        init {
            logging.captureStandardOutput(LogLevel.INFO)
            logging.captureStandardError(LogLevel.INFO)
        }
    }

    open class DockerCreateVolume : AbstractDockerVolume() {

        init {
            outputs.upToDateWhen {
                exists()
            }
        }

        @TaskAction
        fun create() {
            project.exec {
                commandLine = listOf("docker", "volume", "create", volume.get())
            }
        }
    }

    open class DockerRemoveVolume : AbstractDockerVolume() {
        init {
            @Suppress("LeakingThis")
            onlyIf {
                exists()
            }
        }

        @TaskAction
        fun remove() {
            project.exec {
                commandLine = listOf("docker", "volume", "rm", volume.get())
            }
        }
    }
}