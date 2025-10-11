package plugins

import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.kotlin.dsl.extra
import org.gradle.kotlin.dsl.*
import org.gradle.process.ExecOperations
import org.gradle.process.ExecSpec
import java.io.ByteArrayOutputStream
import javax.inject.Inject

// Calculate once, share everywhere, configuration properties.
// Applied to the root project.
// Should be included before all other plugins.
@Suppress("unused")
class SharedPropertiesPlugin : Plugin<Project> {

    companion object {
        // Capture stdout from running a command.
        fun Project.execCaptureOutput(command: List<String>, message: String): String {
            return try {
                val process = ProcessBuilder(command).start()
                val output = process.inputStream.bufferedReader().readText()
                val error = process.errorStream.bufferedReader().readText()
                
                error.let {
                    if (it.isNotBlank()) {
                        logger.info(it)
                    }
                }
                
                val exitCode = process.waitFor()
                if (exitCode != 0) throw RuntimeException(message)
                output.trim()
            } catch (e: Exception) {
                throw RuntimeException(message, e)
            }
        }

        val Project.branch: String
            get() = rootProject.extra["git.branch"] as String

        val Project.commit: String
            get() = rootProject.extra["git.commit"] as String

        val Project.tag: String
            get() = rootProject.extra["git.tag"] as String

        val Project.isLatestTag: Boolean
            get() = rootProject.extra["git.latest"] as Boolean

        val Project.isleRepository: String
            get() = properties.getOrDefault("isle.repository", "islandora") as String

        val Project.isleTag: String
            get() = properties.getOrDefault("isle.tag", "local") as String

        fun String.normalizeDockerTag() = this.replace("""[^a-zA-Z0-9._-]""".toRegex(), "-")
    }

    override fun apply(pluginProject: Project): Unit = pluginProject.run {
        rootProject.extra["git.branch"] = execCaptureOutput(
            listOf("git", "rev-parse", "--abbrev-ref", "HEAD"),
            "Failed to get branch."
        ).normalizeDockerTag()

        rootProject.extra["git.commit"] =
            execCaptureOutput(listOf("git", "rev-parse", "HEAD"), "Failed to get commit hash.")

        rootProject.extra["git.tag"] = try {
            execCaptureOutput(
                listOf("git", "describe", "--exact-match", "--tags", "HEAD"),
                "HEAD is not a tag."
            )
        } catch (e: Exception) {
            ""
        }

        // Latest is true if HEAD is a tag and that tag has the highest semantic value.
        // Exclude alpha, betas, etc
        rootProject.extra["git.latest"] = execCaptureOutput(
            listOf("git", "tag", "-l", "*.*.*", "--sort=version:refname"),
            "Could not get tags."
        ).lines().last {
            !it.contains("-") // Exclude alpha, betas, etc
        } == tag

        rootProject.extra["git.sourceDateEpoch"] =
            execCaptureOutput(listOf("git", "log", "-1", "--pretty=%ct"), "Failed to get the date of HEAD")
    }
}
