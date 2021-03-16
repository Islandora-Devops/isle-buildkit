package tasks

import com.github.dockerjava.api.DockerClient
import com.github.dockerjava.core.DefaultDockerClientConfig
import com.github.dockerjava.core.DockerClientBuilder
import com.github.dockerjava.httpclient5.ApacheDockerHttpClient
import org.gradle.api.DefaultTask
import org.gradle.api.tasks.Internal
import org.gradle.kotlin.dsl.provideDelegate
import org.gradle.kotlin.dsl.withType

abstract class DockerClientTask : DefaultTask() {

    @get:Internal
    protected val dockerClient: DockerClient by lazy {
        val configBuilder = DefaultDockerClientConfig.createDefaultConfigBuilder().build()
        val httpClient = ApacheDockerHttpClient.Builder()
            .dockerHost(configBuilder.dockerHost)
            .sslConfig(configBuilder.sslConfig)
            .build()
        val dockerClient = DockerClientBuilder
            .getInstance()
            .withDockerHttpClient(httpClient)
            .build()
        project.gradle.buildFinished {
            dockerClient.close()
        }
        dockerClient
    }

    private val parents by lazy {
        project.run {
            generateSequence(this) { it.parent }
        }
    }

    protected fun defaultImageId() = project.run {
        project.provider {
            // Find the first parent project which has a build task.
            parents.find { project -> project.tasks.matching { it.name == "build" }.isNotEmpty() }!!.run {
                val repository = properties["repository"] as String
                val tag = (rootProject.properties["tags"] as String)
                    .split(' ')
                    .filter { it.isNotEmpty() }
                    .map { it.trim() }
                    .first()
                "${repository}/${name}:${tag}"
            }
        }
    }

    protected fun defaultApproximateImageDigestTask() = project.run {
        // Find the first parent project which has a ApproximateImageDigestTask task.
        parents.find { project -> project.tasks.withType<ApproximateImageDigestTask>().isNotEmpty() }!!.run {
            project.tasks.named("digest", ApproximateImageDigestTask::class.java)
        }
    }
}