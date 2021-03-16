package plugins

import com.bmuschko.gradle.docker.DockerRemoteApiPlugin
import com.bmuschko.gradle.docker.tasks.container.*
import com.github.dockerjava.api.exception.NotModifiedException
import groovy.json.JsonSlurper
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.kotlin.dsl.*
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.StringWriter

@Suppress("UnstableApiUsage")
class SingleContainerTest : Plugin<Project> {

    @Suppress("UNCHECKED_CAST")
    override fun apply(project: Project): Unit = project.run {
        apply<DockerRemoteApiPlugin>()

        val repository = project.rootProject.properties["repository"] as String
        val tag = (project.rootProject.properties["tags"] as String)
            .split(' ')
            .filter { it.isNotEmpty() }
            .map { it.trim() }
            .first()

        val inspect by tasks.registering {
            val inspectOutput by extra(objects.fileProperty())
            inspectOutput.set(buildDir.resolve("inspect.json"))
            outputs.file(inspectOutput)
            doLast {
                val image = "local/base:latest"
                project.exec {
                    // Only look at fields which uniquely identify the images contents, ignore things that would
                    // result in cache misses like dates, etc.
                    commandLine = listOf("docker", "inspect", "--format", """{ "Config": {{ json .Config }}, "RootFS": {{ json .RootFS }} }""", image)
                    standardOutput = inspectOutput.get().asFile.outputStream()
                }
            }
        }

        val computeImageId by tasks.registering() {
            doLast {
                val image = "local/base:latest"
                ByteArrayOutputStream().use { archive ->
                    project.exec {
                        commandLine = listOf("docker", "save", image)
                        standardOutput = archive
                    }
                    ByteArrayOutputStream().use { output ->
                        project.exec {
                            commandLine = listOf("tar", "-x", "manifest.json", "-O")
                            standardInput = ByteArrayInputStream(archive.toByteArray())
                            standardOutput = output
                        }
                        val json =
                            JsonSlurper().parseText(output.toString()) as ArrayList<Map<*, *>> // Who has time for types.
                        val config = json[0]["Config"]!! as String
                        project.exec {
                            commandLine = listOf("tar", "-x", config, "-O")
                            standardInput = ByteArrayInputStream(archive.toByteArray())
                            output.reset()
                            standardOutput = output
                        }
                        logger.quiet(output.toString())
                    }
                }
            }
        }

        val createContainer by tasks.registering(DockerCreateContainer::class) {
            // Find the first parent project which has a build task.
            val dockerProject = generateSequence(parent) { it.parent }.find { project ->
                project.tasks.matching { it.name == "build" }.isNotEmpty()
            }!!
            imageId.set("${repository}/${dockerProject.name}:${tag}")
            dependsOn(dockerProject.tasks.named("build"))
        }

        val startContainer by tasks.registering(DockerStartContainer::class) {
            containerId.set(createContainer.map { it.containerId.get() })
        }

        val logContainer by tasks.registering(DockerLogsContainer::class) {
            containerId.set(startContainer.map { it.containerId.get() })
            sink = StringWriter()
            doLast {
                // Display for debugging purposes.
                logger.info(sink.toString())
            }
        }

        val stopContainer by tasks.registering(DockerStopContainer::class) {
            containerId.set(startContainer.map { it.containerId.get() })
            onError {
                // Ignore if the container has already been stopped.
                if (this !is NotModifiedException) {
                    throw this
                }
            }
            finalizedBy(logContainer)
        }

        val removeContainer by tasks.registering(DockerRemoveContainer::class) {
            containerId.set(createContainer.map { it.containerId.get() })
            val status by extra(objects.property<String>())
            val exitCode by extra(objects.property<Long>())
            doFirst {
                // The container should be stopped by this point, check its exit code store the result and in do last, throw an
                // error if non-zero.
                val result = dockerClient.inspectContainerCmd(containerId.get()).exec()
                status.set(result.state.status)
                exitCode.set(result.state.exitCodeLong)
            }
            doLast {
                if (status.get() != "exited" || exitCode.get() != 0L) {
                    throw RuntimeException("Container ${createContainer.get().imageId.get()} (${containerId.get()}) exited with ${exitCode.get()} and status ${status.get()}.")
                }
            }
            dependsOn(stopContainer)
        }

        val waitForContainer by tasks.registering(DockerWaitContainer::class) {
            containerId.set(startContainer.map { it.containerId.get() })
            awaitStatusTimeout.set(30) // Maximum time to run test.
            finalizedBy(removeContainer)
        }

    }
}
