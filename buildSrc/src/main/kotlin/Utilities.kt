import org.gradle.api.Project
import java.io.ByteArrayOutputStream
import java.io.File

fun Project.execCaptureOutput(command: List<String>, error: String) = ByteArrayOutputStream().use { output ->
    val result = this.exec {
        standardOutput = output
        commandLine = command
    }
    if (result.exitValue != 0) throw RuntimeException(error)
    output.toString()
}.trim()