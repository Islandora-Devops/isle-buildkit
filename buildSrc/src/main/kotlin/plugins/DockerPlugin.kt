package plugins

import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.tasks.Exec
import org.gradle.kotlin.dsl.apply
import org.gradle.kotlin.dsl.register
import java.io.ByteArrayInputStream


// Delete inactive tags, and other administrative tasks.
@Suppress("unused")
class DockerPlugin : Plugin<Project> {
    companion object {
        // Pushing may require logging in to the repository, if so these need to be populated.
        // The local registry does not require credentials.
        val Project.isleBuildRegistryHost: String
            get() = properties.getOrDefault("isle.build.registry.host", "docker.io") as String

        // Pushing may require logging in to the repository, if so these need to be populated.
        // The local registry does not require credentials.
        val Project.isleBuildRegistryUser: String
            get() = properties.getOrDefault("isle.build.registry.user", "") as String

        val Project.isleBuildRegistryPassword: String
            get() = properties.getOrDefault("isle.build.registry.password", "") as String

        fun String.normalizeDockerTag() = this.replace("""[^a-zA-Z0-9._-]""".toRegex(), "-")
    }

    override fun apply(pluginProject: Project): Unit = pluginProject.run {
        apply<SharedPropertiesPlugin>()
        tasks.register<Exec>("login") {
            group = "Isle Build"
            description = "Logs into the docker registry required for pushing if applicable"
            standardInput = ByteArrayInputStream(project.isleBuildRegistryPassword.toByteArray())
            commandLine = listOf(
                "docker",
                "login",
                "--username",
                project.isleBuildRegistryUser,
                "--password-stdin",
                project.isleBuildRegistryHost
            )
            onlyIf {
                project.isleBuildRegistryUser.isNotBlank() && project.isleBuildRegistryPassword.isNotBlank()
            }
        }
    }
}
