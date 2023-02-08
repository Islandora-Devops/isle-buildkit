package plugins

import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.tasks.*
import org.gradle.kotlin.dsl.*
import plugins.CertificateGenerationPlugin.GenerateCerts
import tasks.DockerContainer.*
import tasks.DockerNetwork.DockerCreateNetwork
import tasks.DockerNetwork.DockerRemoveNetwork
import tasks.DockerVolume.DockerCreateVolume
import tasks.DockerVolume.DockerRemoveVolume

// Creates a docker registry hosted locally with the given parameters that can be used by buildkit.
@Suppress("unused")
class RegistryPlugin : Plugin<Project> {

    companion object {
        // It's important to note that we’re using a domain containing a "." here, i.e. localhost.domain.
        // If it were missing Docker would believe that localhost is a username, as in localhost/ubuntu.
        // It would then try to push to the default Central Registry rather than our local repository.
        // *.islandora.dev makes for a good default as we can generate certificates for it and avoid many problems.
        val Project.isleLocalRegistryDomain: String
            get() = properties.getOrDefault("isle.local.registry.domain", "islandora.io") as String

        val Project.isleLocalRegistryPort: Int
            get() = (properties.getOrDefault("isle.local.registry.port", "443") as String).toInt()

        val Project.isleLocalBindPort: Boolean
            get() = (properties.getOrDefault("isle.local.registry.bind.port", "false") as String).toBoolean()

        // The container should have the same name as the domain so that buildkit builder can find it by name.
        val Project.isleLocalRegistryContainer: String
            get() = properties.getOrDefault("isle.local.registry.container", "isle-registry") as String

        val Project.isleLocalRegistryNetwork: String
            get() = properties.getOrDefault("isle.local.registry.network", "isle-registry") as String

        val Project.isleLocalRegistryVolume: String
            get() = properties.getOrDefault("isle.local.registry.volume", "isle-registry") as String

        val Project.isleLocalRegistryImage: String
            get() = properties.getOrDefault("isle.local.registry.image", "registry:2") as String
    }

    open class CreateRegistry : DockerCreateContainer() {
        @Input
        val domain = project.objects.property<String>().convention(project.isleLocalRegistryDomain)

        @Input
        val port = project.objects.property<Int>().convention(project.isleLocalRegistryPort)

        @Input
        val bindPort = project.objects.property<Boolean>().convention(project.isleLocalBindPort)

        @Input
        val network = project.objects.property<String>().convention(project.isleLocalRegistryNetwork)

        @Input
        val volume = project.objects.property<String>().convention(project.isleLocalRegistryVolume)

        @InputFile
        @PathSensitive(PathSensitivity.RELATIVE)
        val cert = project.objects.fileProperty()

        @InputFile
        @PathSensitive(PathSensitivity.RELATIVE)
        val key = project.objects.fileProperty()

        @InputFile
        @PathSensitive(PathSensitivity.RELATIVE)
        val rootCA = project.objects.fileProperty()

        @get:Internal
        val registry: String
            get() = if (setOf(80, 443).contains(port.get())) domain.get() else "${domain.get()}:${port.get()}"

        init {
            options.addAll(project.provider {
                listOf(
                    "--network=${network.get()}",
                    "--network-alias=${domain.get()}",
                    "--env", "REGISTRY_HTTP_ADDR=0.0.0.0:${port.get()}",
                    "--env", "REGISTRY_STORAGE_DELETE_ENABLED=true",
                    "--env", "REGISTRY_HTTP_TLS_CERTIFICATE=/usr/local/share/ca-certificates/cert.pem",
                    "--env", "REGISTRY_HTTP_TLS_KEY=/usr/local/share/ca-certificates/privkey.pem",
                    "--volume=${cert.get().asFile.absolutePath}:/usr/local/share/ca-certificates/cert.pem:ro",
                    "--volume=${key.get().asFile.absolutePath}:/usr/local/share/ca-certificates/privkey.pem:ro",
                    "--volume=${rootCA.get().asFile.absolutePath}:/usr/local/share/ca-certificates/rootCA.pem:ro",
                    "--volume=${volume.get()}:/var/lib/registry",
                ) + if (bindPort.get()) listOf("-p", "${port.get()}:${port.get()}") else emptyList()
            })
        }
    }

    override fun apply(pluginProject: Project): Unit = pluginProject.run {
        apply<SharedPropertiesPlugin>()
        apply<CertificateGenerationPlugin>()

        val stopRegistry by tasks.registering(DockerStopContainer::class) {
            group = "Isle Registry"
            description = "Stops the local registry"
            name.set(isleLocalRegistryContainer)
        }

        val destroyRegistry by tasks.registering(DockerRemoveContainer::class) {
            group = "Isle Registry"
            description = "Destroys the local registry"
            name.set(isleLocalRegistryContainer)
            dependsOn(stopRegistry)
            finalizedBy("destroyRegistryNetwork", "destroyRegistryVolume")
        }

        val destroyRegistryVolume by tasks.registering(DockerRemoveVolume::class) {
            group = "Isle Registry"
            description = "Destroys the local docker registry volume"
            volume.set(isleLocalRegistryVolume)
            dependsOn(destroyRegistry) // Cannot remove volumes of active containers.
        }

        val destroyRegistryNetwork by tasks.registering(DockerRemoveNetwork::class) {
            group = "Isle Registry"
            description = "Destroys the local docker registry network"
            network.set(isleLocalRegistryNetwork)
            dependsOn(destroyRegistry) // Cannot remove networks of active containers.
        }

        val createRegistryVolume by tasks.registering(DockerCreateVolume::class) {
            group = "Isle Registry"
            description = "Creates a volume for the local docker registry"
            volume.set(isleLocalRegistryVolume)
            mustRunAfter(destroyRegistryVolume)
        }

        val createRegistryNetwork by tasks.registering(DockerCreateNetwork::class) {
            group = "Isle Registry"
            description = "Creates a network for the local docker registry"
            network.set(isleLocalRegistryNetwork)
            mustRunAfter(destroyRegistryNetwork)
        }

        val generateCertificates = tasks.named<GenerateCerts>("generateCertificates")

        val createRegistry by tasks.registering(CreateRegistry::class) {
            group = "Isle Registry"
            description = "Starts a the local docker registry if not already running"
            name.set(isleLocalRegistryContainer)
            image.set(isleLocalRegistryImage)
            network.set(createRegistryNetwork.map { it.network.get() })
            volume.set(createRegistryVolume.map { it.volume.get() })
            cert.set(generateCertificates.flatMap { it.cert })
            key.set(generateCertificates.flatMap { it.key })
            rootCA.set(generateCertificates.flatMap { it.rootCA })
            mustRunAfter(destroyRegistry)
        }

        tasks.register<DockerStartContainer>("startRegistry") {
            group = "Isle Registry"
            description = "Starts the local registry"
            name.set(isleLocalRegistryContainer)
            dependsOn(createRegistry)
            doLast {
                // Add docker cli and buildx, so we can use image tools from within the registry network.
                // apk add docker-cli-buildx
                project.exec {
                    commandLine("docker", "exec", isleLocalRegistryContainer, "apk", "add", "docker-cli-buildx")
                }
                project.exec {
                    commandLine("docker", "exec", isleLocalRegistryContainer, "update-ca-certificates")
                }
            }
        }

    }
}
