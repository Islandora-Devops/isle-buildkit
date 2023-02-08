package tasks

import com.fasterxml.jackson.databind.ObjectMapper
import org.apache.commons.io.output.ByteArrayOutputStream
import org.apache.commons.io.output.NullOutputStream
import org.gradle.api.DefaultTask
import org.gradle.api.logging.LogLevel
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.Internal
import org.gradle.api.tasks.TaskAction
import org.gradle.kotlin.dsl.listProperty
import org.gradle.kotlin.dsl.property
import org.gradle.kotlin.dsl.provideDelegate

@Suppress("unused")
class DockerContainer {

    abstract class AbstractNamedDockerContainer : DefaultTask() {
        @Internal
        protected val baseArguments = listOf("docker", "container")

        @Input
        val name = project.objects.property<String>()

        private val inspect by lazy {
            ByteArrayOutputStream().use { output ->
                project.exec {
                    commandLine(baseArguments + listOf("inspect", name.get()))
                    standardOutput = output
                    errorOutput = NullOutputStream()
                    isIgnoreExitValue = true
                }.let { result ->
                    if (result.exitValue == 0) output.toString() else null
                }
            }?.let { json ->
                ObjectMapper().readTree(json)
            }
        }

        protected fun exists() = inspect !== null

        protected fun running() = inspect?.get(0)?.get("State")?.get("Running")?.asBoolean() ?: false

        init {
            logging.captureStandardOutput(LogLevel.INFO)
            logging.captureStandardError(LogLevel.INFO)
        }
    }

    open class DockerCreateContainer : AbstractNamedDockerContainer() {

        @Input
        val options = project.objects.listProperty<String>()

        @Input
        val image = project.objects.property<String>()

        @Input
        val arguments = project.objects.listProperty<String>()

        init {
            @Suppress("LeakingThis") onlyIf {
                !exists()
            }
            // Need to have a name, so we can refer to it.
            options.add(name.map { "--name=${it}" })
        }

        @TaskAction
        fun create() {
            project.exec {
                commandLine = baseArguments + listOf(
                    "create"
                ) + options.get() + listOf(image.get()) + arguments.get()
            }
        }
    }

    open class DockerStartContainer : AbstractNamedDockerContainer() {
        init {
            @Suppress("LeakingThis") onlyIf {
                !running()
            }
        }

        @TaskAction
        fun start() {
            project.exec {
                commandLine = baseArguments + listOf("start", name.get())
            }
        }
    }

    open class DockerStopContainer : AbstractNamedDockerContainer() {
        init {
            @Suppress("LeakingThis") onlyIf {
                exists()
            }
        }

        @TaskAction
        fun stop() {
            project.exec {
                commandLine = baseArguments + listOf("stop", name.get())
            }
        }
    }

    open class DockerRemoveContainer : AbstractNamedDockerContainer() {
        init {
            @Suppress("LeakingThis") onlyIf {
                exists()
            }
        }

        @TaskAction
        fun remove() {
            project.exec {
                commandLine = baseArguments + listOf("rm", name.get())
            }
        }
    }
}