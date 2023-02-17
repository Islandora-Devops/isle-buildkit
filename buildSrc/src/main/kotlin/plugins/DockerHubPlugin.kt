package plugins

import com.fasterxml.jackson.core.JsonFactory
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.databind.DeserializationFeature
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.KotlinModule
import org.apache.commons.io.output.ByteArrayOutputStream
import org.gradle.api.DefaultTask
import org.gradle.api.GradleException
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.provider.Property
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.Internal
import org.gradle.api.tasks.OutputFile
import org.gradle.api.tasks.TaskAction
import org.gradle.kotlin.dsl.*
import org.gradle.workers.WorkAction
import org.gradle.workers.WorkParameters
import org.gradle.workers.WorkQueue
import org.gradle.workers.WorkerExecutor
import plugins.IslePlugin.Companion.isDockerProject
import java.net.URI
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import javax.inject.Inject


// Delete inactive tags, and other administrative tasks.
@Suppress("unused")
class DockerHubPlugin : Plugin<Project> {
    companion object {
        // User to use when authenticating against DockerHub.
        val Project.dockerHubUsername: String
            get() = properties.getOrDefault("isle.dockerhub.user", "islandoracommunity") as String

        // Personal access token use to log in to DockerHub.
        val Project.dockerHubPersonalAccessToken: String
            get() = properties.getOrDefault("isle.dockerhub.personal.access.token", "") as String

        // The repository to remove tags from.
        val Project.dockerHubRepository: String
            get() = properties.getOrDefault("isle.dockerhub.repository", "islandora") as String

        // Only remove tags that are marked as "Inactive".
        val Project.removeInactiveOnly: Boolean
            get() = (properties.getOrDefault("isle.dockerhub.remove.inactive.only", "true") as String).toBoolean()

        // Additional tags aside from branches and tags in the repository to prevent the deletion of.
        // List of values separated by comma.
        val Project.dockerHubProtectedTags: Set<String>
            get() = (properties.getOrDefault("isle.dockerhub.protected.tags", "") as String)
                .split(',')
                .filter { it.isNotBlank() }
                .toSet()
    }

    open class ProtectedDockerHubTags : DefaultTask() {
        @Input
        val images = project.objects.setProperty<String>()

        @Input
        val excludeTags = project.objects.setProperty<String>().convention(project.dockerHubProtectedTags)

        @OutputFile
        val protectedTagsFile =
            project.objects.fileProperty().convention(project.layout.buildDirectory.file("protected.tags.txt"))

        @get:Internal
        val protectedTags: Set<String>
            get() = protectedTagsFile.get().asFile.readLines().toSet()

        init {
            // Always re-run.
            outputs.upToDateWhen { false }
        }

        @TaskAction
        fun exec() {
            project.exec {
                commandLine = listOf("git", "fetch", "--all")
                workingDir = project.projectDir
            }

            val gitTags = ByteArrayOutputStream().use { output ->
                project.exec {
                    commandLine = listOf("git", "tag", "-l")
                    workingDir = project.projectDir
                    standardOutput = output
                }
                output.toString()
            }.lines()

            val gitBranches = ByteArrayOutputStream().use { output ->
                project.exec {
                    commandLine = listOf("git", "branch", "-r")
                    workingDir = project.projectDir
                    standardOutput = output
                }
                output.toString()
            }.lines()
                .filterNot { it.contains("^.*/HEAD".toRegex()) } // Ignore HEAD
                .map { it.replace(".*/".toRegex(), "") } // Strip remotes.

            val imageTags: Set<String> = (gitTags + gitBranches + excludeTags.get())
                .plus("latest") // Never delete latest
                .filter { it.isNotBlank() }
                .toSet()

            val archTags = listOf("amd64", "arm64").flatMap { suffix ->
                imageTags.map { "${it}-${suffix}" }
            }

            val cacheTags = images.get().flatMap { image ->
                archTags.map { "${image}-${it}" }
            }

            val allTags = imageTags + archTags + cacheTags

            protectedTagsFile.get().asFile.writeText(allTags.joinToString("\n"))
        }
    }

    open class GetDockerHubAuthenticationToken : DefaultTask() {

        @Input
        val dockerHubUsername = project.objects.property<String>().convention(project.dockerHubUsername)

        @Input
        val dockerHubPassword = project.objects.property<String>().convention(project.dockerHubPersonalAccessToken)

        // Explicitly not stored to a file as we do not want to leak/persist this value anywhere.
        @Internal
        val token = project.objects.property<String>()

        @TaskAction
        fun exec() {
            val objectMapper = ObjectMapper()
            val credentials = mapOf("username" to dockerHubUsername.get(), "password" to dockerHubPassword.get())
            val body = objectMapper.writeValueAsString(credentials)

            val client = HttpClient.newBuilder().build()
            val request = HttpRequest.newBuilder()
                .header("Content-Type", "application/json")
                .uri(URI.create("https://hub.docker.com/v2/users/login/"))
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .build()

            val response = client.send(request, HttpResponse.BodyHandlers.ofString())
            if (response.statusCode() == 200) {
                token.set(objectMapper.readTree(response.body()).get("token").asText().trim())
            } else {
                throw GradleException(response.body().toString())
            }
        }
    }

    open class GetDockerHubTagsEligibleForDeletion : DefaultTask() {

        data class ListTagsResult(val name: String, val tag_status: String)
        data class ListTagsResponse(val count: Int, val next: String?, val results: List<ListTagsResult>)

        @Input
        val repository = project.objects.property<String>().convention(project.dockerHubRepository)

        @Input
        val image = project.objects.property<String>()

        @Input
        val protectedTags = project.objects.setProperty<String>()

        @Input
        val removeInactiveOnly = project.objects.property<Boolean>().convention(project.removeInactiveOnly)

        @Input
        val token = project.objects.property<String>()

        // Explicitly not stored to a file as we do not want to leak/persist this value anywhere.
        @OutputFile
        val tagsToRemoveFile =
            project.objects.fileProperty().convention(project.layout.buildDirectory.file("remove.tags.txt"))

        @get:Internal
        val tagsToRemove: Set<String>
            get() = tagsToRemoveFile.get().asFile.readText().lines().toSet()

        init {
            // Always re-run.
            outputs.upToDateWhen { false }
        }

        @TaskAction
        fun exec() {
            val client = HttpClient.newBuilder().build()
            val tags = mutableSetOf<String>()
            var url =
                "https://hub.docker.com/v2/namespaces/${repository.get()}/repositories/${image.get()}/tags?page_size=100"
            do {
                val request = HttpRequest.newBuilder()
                    .header("Content-Type", "application/json")
                    .header("Authorization", "JWT ${token.get()}")
                    .uri(URI.create(url))
                    .build()

                val response = client.send(request, HttpResponse.BodyHandlers.ofString())
                val objectMapper = ObjectMapper(JsonFactory())
                    .registerModule(KotlinModule.Builder().build())
                    .configure(JsonParser.Feature.ALLOW_UNQUOTED_FIELD_NAMES, true)
                    .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)

                val jsonResponse = objectMapper.readValue(response.body(), ListTagsResponse::class.java)!!

                var results = jsonResponse.results.filterNot {
                    protectedTags.get().contains(it.name)
                } // Ignore protected tags && active tags.

                if (removeInactiveOnly.get()) { // Ignore "active" tags.
                    results = results.filter { it.tag_status == "inactive" }
                }
                tags.addAll(results.map { it.name })

                url = jsonResponse.next ?: ""
            } while (jsonResponse.next != null)

            tagsToRemoveFile.get().asFile.writeText(tags.joinToString("\n"))
        }
    }

    interface DeleteTagParameters : WorkParameters {
        val repository: Property<String>
        val image: Property<String>
        val tag: Property<String>
        val token: Property<String>
    }

    abstract class DeleteTagsAction : WorkAction<DeleteTagParameters> {
        override fun execute() {
            val request = HttpRequest.newBuilder()
                .header("Content-Type", "application/json")
                .header("Authorization", "JWT ${parameters.token.get()}")
                .DELETE()
                .uri(URI.create("https://hub.docker.com/v2/repositories/${parameters.repository.get()}/${parameters.image.get()}/tags/${parameters.tag.get()}"))
                .build()
            HttpClient.newBuilder().build().send(request, HttpResponse.BodyHandlers.ofString())
        }
    }


    open class DeleteEligibleTags @Inject constructor(private val workerExecutor: WorkerExecutor) : DefaultTask() {

        @Input
        val repository = project.objects.property<String>().convention(project.dockerHubRepository)

        @Input
        val image = project.objects.property<String>()

        @Input
        val tags = project.objects.setProperty<String>()

        @Input
        val token = project.objects.property<String>()

        @TaskAction
        fun exec() {
            val workQueue: WorkQueue = workerExecutor.noIsolation()
            tags.get().forEach {
                workQueue.submit(DeleteTagsAction::class.java) {
                    image.set(this@DeleteEligibleTags.image.get())
                    repository.set(this@DeleteEligibleTags.repository.get())
                    tag.set(it)
                    token.set(this@DeleteEligibleTags.token.get())
                }
            }
        }

    }

    override fun apply(pluginProject: Project): Unit = pluginProject.run {
        apply<SharedPropertiesPlugin>()

        val getProtectedDockerHubTags by tasks.registering(ProtectedDockerHubTags::class) {
            group = "Isle DockerHub"
            description = "Gets the tags which should not be removed by DockerHub cleanup inactive tags task."
            images.set(allprojects.filter { it.isDockerProject }.map { it.name })
        }

        val getDockerHubToken by tasks.registering(GetDockerHubAuthenticationToken::class) {
            group = "Isle DockerHub"
            description = "Gets the login token required for interacting with DockerHub Rest API."
        }

        allprojects {
            if (isDockerProject) {
                val getDockerHubTagsEligibleForDeletion by tasks.registering(GetDockerHubTagsEligibleForDeletion::class) {
                    group = "Isle DockerHub"
                    description =
                        "Gets the tags eligible for removal from DockerHub 'islandora/${project.name}' Repository."
                    image.set(project.name)
                    protectedTags.set(getProtectedDockerHubTags.map { it.protectedTags })
                    token.set(getDockerHubToken.map { it.token.get() })
                }

                tasks.register<DeleteEligibleTags>("deleteEligibleDockerHubTags") {
                    group = "Isle DockerHub"
                    description = "Delete eligible tags from DockerHub 'islandora/${project.name}' Repository."
                    image.set(project.name)
                    tags.set(getDockerHubTagsEligibleForDeletion.map { it.tagsToRemove })
                    token.set(getDockerHubToken.map { it.token.get() })
                }
            }
        }

        // Cache repository.
        val getDockerHubTagsEligibleForDeletion by tasks.registering(GetDockerHubTagsEligibleForDeletion::class) {
            group = "Isle DockerHub"
            description = "Gets the tags eligible for removal from DockerHub 'islandora/cache' Repository."
            image.set("cache")
            protectedTags.set(getProtectedDockerHubTags.map { it.protectedTags })
            token.set(getDockerHubToken.map { it.token.get() })
        }

        tasks.register<DeleteEligibleTags>("deleteEligibleDockerHubTags") {
            group = "Isle DockerHub"
            description = "Delete eligible tags from DockerHub 'islandora/cache' Repository."
            image.set("cache")
            tags.set(getDockerHubTagsEligibleForDeletion.map { it.tagsToRemove })
            token.set(getDockerHubToken.map { it.token.get() })
        }
    }
}
