package plugins

import org.gradle.api.*
import org.gradle.api.logging.LogLevel
import org.gradle.api.model.ObjectFactory
import org.gradle.api.provider.ProviderFactory
import org.gradle.api.tasks.*
import org.gradle.internal.jvm.Jvm
import org.gradle.kotlin.dsl.*
import org.gradle.nativeplatform.platform.internal.DefaultNativePlatform
import plugins.CertificateGenerationPlugin.CertificateGenerationExtension.Companion.certificates
import plugins.SharedPropertiesPlugin.Companion.execCaptureOutput
import tasks.Download
import java.nio.file.Files.setPosixFilePermissions

// Downloads and executes mkcert to generate development certificates.
@Suppress("unused")
class CertificateGenerationPlugin : Plugin<Project> {

    open class CertificateGenerationExtension constructor(objects: ObjectFactory, providers: ProviderFactory) {
        open class MkCertExtension(private val name: String) : Named {
            var sha256: String = ""
            var platform: Boolean = false
            override fun getName(): String = name
        }

        val os = DefaultNativePlatform.getCurrentOperatingSystem()!!
        val arch = DefaultNativePlatform.getCurrentArchitecture()!!

        var version = "v1.4.4"
        var baseUrl = "https://github.com/FiloSottile/mkcert/releases/download"
        var domains = listOf(
            "*.islandora.dev",
            "islandora.dev",
            "*.islandora.io",
            "islandora.io",
            "*.islandora.info",
            "islandora.info",
            "localhost",
            "127.0.0.1",
            "::1",
        )

        internal val executables = objects.domainObjectContainer(MkCertExtension::class.java)

        fun mkcert(name: String, action: Action<MkCertExtension>) {
            executables.create(name, action)
        }

        val mkcert: MkCertExtension
            get() = executables.find { it.platform }!!

        val url = objects.property<String>().convention(providers.provider {
            "${baseUrl}/${version}/${mkcert.name}"
        })

        companion object {
            val Project.certificates: CertificateGenerationExtension
                get() =
                    extensions.findByType() ?: extensions.create("certificates")

            fun Project.certificates(action: Action<CertificateGenerationExtension>) {
                action.execute(certificates)
            }

        }
    }

    open class GenerateCerts : DefaultTask() {

        @InputFile
        @PathSensitive(PathSensitivity.RELATIVE)
        val executable = project.objects.fileProperty()

        @Internal
        val dest = project.objects.directoryProperty().convention(project.layout.buildDirectory.dir("certs"))

        @OutputFile
        val cert = project.objects.fileProperty().convention(dest.map { it.file("cert.pem") })

        @OutputFile
        val key = project.objects.fileProperty().convention(dest.map { it.file("privkey.pem") })

        @OutputFile
        val rootCA = project.objects.fileProperty().convention(dest.map { it.file("rootCA.pem") })

        @OutputFile
        val rootCAKey = project.objects.fileProperty().convention(dest.map { it.file("rootCA-key.pem") })

        @Input
        val arguments = project.objects.listProperty<String>()

        private val executablePath: String
            get() = this@GenerateCerts.executable.get().asFile.absolutePath

        init {
            logging.captureStandardOutput(LogLevel.INFO)
            logging.captureStandardError(LogLevel.INFO)
        }

        private fun execute(vararg arguments: String) {
            project.exec {
                commandLine = listOf(executablePath) + arguments
                // Exclude JAVA_HOME as we only want to check the local certificates for the system.
                environment = Jvm.current().getInheritableEnvironmentVariables(System.getenv()).filterKeys {
                    !setOf("JAVA_HOME").contains(it)
                }
                // Note this is allowed to fail on some systems the user may have to manually install the local certificate.
                // See the README.
                isIgnoreExitValue = true
            }
        }

        private fun install() {
            execute("-install")
            val rootStore =
                project.file(project.execCaptureOutput(listOf(executablePath, "-CAROOT"), "Failed to find CAROOT"))
            listOf(rootCA.get().asFile, rootCAKey.get().asFile).forEach {
                rootStore.resolve(it.name).copyTo(it, true)
            }
        }

        @TaskAction
        fun exec() {
            install()
            execute(
                "-cert-file", cert.get().asFile.absolutePath,
                "-key-file", key.get().asFile.absolutePath,
                *arguments.get().toTypedArray<String>(),
            )
        }

    }

    override fun apply(pluginProject: Project): Unit = pluginProject.run {
        apply<SharedPropertiesPlugin>()
        afterEvaluate {
            certificates {
                // Apply defaults if not provided.
                if (executables.isEmpty()) {
                    mkcert("mkcert-${version}-linux-amd64") {
                        sha256 = "6d31c65b03972c6dc4a14ab429f2928300518b26503f58723e532d1b0a3bbb52"
                        platform = os.isLinux
                    }
                    mkcert("mkcert-${version}-darwin-amd64") {
                        sha256 = "a32dfab51f1845d51e810db8e47dcf0e6b51ae3422426514bf5a2b8302e97d4e"
                        platform = os.isMacOsX && arch.isAmd64
                    }
                    mkcert("mkcert-${version}-darwin-arm64") {
                        sha256 = "c8af0df44bce04359794dad8ea28d750437411d632748049d08644ffb66a60c6"
                        platform = os.isMacOsX && arch.isArm
                    }
                    mkcert("mkcert-${version}-windows-amd64.exe") {
                        sha256 = "d2660b50a9ed59eada480750561c96abc2ed4c9a38c6a24d93e30e0977631398"
                        platform = os.isWindows
                    }
                }
            }
        }

        val downloadMkCert by tasks.registering(Download::class) {
            group = "Isle Certificates"
            description = "Downloads mkcert for generating development certificates"
            url.set(certificates.url)
            sha256.set(certificates.mkcert.sha256)
            doLast {
                if (!certificates.os.isWindows) {
                    // Make all downloaded files executable.
                    val perms = setOf(
                        java.nio.file.attribute.PosixFilePermission.OWNER_READ,
                        java.nio.file.attribute.PosixFilePermission.OWNER_EXECUTE,
                        java.nio.file.attribute.PosixFilePermission.GROUP_READ,
                        java.nio.file.attribute.PosixFilePermission.GROUP_EXECUTE,
                        java.nio.file.attribute.PosixFilePermission.OTHERS_READ,
                        java.nio.file.attribute.PosixFilePermission.OTHERS_EXECUTE,
                    )
                    setPosixFilePermissions(dest.get().asFile.toPath(), perms)
                }
            }
        }

        tasks.register<GenerateCerts>("generateCertificates") {
            group = "Isle Certificates"
            description = "Generates development certificates"
            executable.set(downloadMkCert.flatMap { it.dest })
            arguments.set(certificates.domains)
        }
    }
}
