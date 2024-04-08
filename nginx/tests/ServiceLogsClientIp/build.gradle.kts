import plugins.TestsPlugin.DockerComposeUp
import java.io.ByteArrayOutputStream

tasks.named<DockerComposeUp>("test") {
    doLast {
        // get the docker logs from our nginx service
        val outputStream = ByteArrayOutputStream()
        project.exec {
            commandLine = baseArguments + listOf("logs")
            standardOutput = outputStream
            workingDir = project.projectDir
        }
        val output = outputStream.toString()

        // see if the log has a match for the IP we set in the test.sh cURL -H command
        val pattern = "nginx-1  | 1.2.3.4"
        val matchingLines = output.lines().filter { line ->
            line.startsWith(pattern)
        }

        // fail the test if we didn't find any logs with the IP
        if (matchingLines.isEmpty()) {
            throw GradleException("No lines found starting with '$pattern'")
        }
    }
}
