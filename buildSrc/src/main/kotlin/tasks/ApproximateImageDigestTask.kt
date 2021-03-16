package tasks

import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import com.github.dockerjava.api.command.RootFS
import com.github.dockerjava.api.model.ContainerConfig
import org.gradle.api.tasks.Internal
import org.gradle.api.tasks.OutputFile
import org.gradle.api.tasks.TaskAction
import org.gradle.kotlin.dsl.property

// Not actually the image digest but rather an approximation that ignores timestamps, etc.
// So we do not run test unless the image has actually changed, it only checks contents & configuration.
@Suppress("UnstableApiUsage")
open class ApproximateImageDigestTask : DockerClientTask() {

    data class ApproximateDigest(val config: ContainerConfig, val rootFS: RootFS)

    // Not marked as input as the tag can change but the image contents may be the same so we do not want to rerun.
    @Internal
    val imageId = project.objects.property<String>().convention(defaultImageId())

    // A json file whose contents can be used to uniquely identify an image by contents. We do not actually need to
    // generate a sha-256 as Gradle will do that when computing dependencies between tasks.
    @OutputFile
    val digest =
        project.objects.fileProperty().convention(project.layout.buildDirectory.file("approximate-image-digest.json"))

    @TaskAction
    fun exec() {
        dockerClient.inspectImageCmd(imageId.get()).exec().run {
            digest.get().asFile.writeText(jacksonObjectMapper().writeValueAsString(ApproximateDigest(config, rootFS)))
        }
    }
}