import plugins.TestsPlugin.DockerComposeUp
import java.io.ByteArrayOutputStream

tasks.named<DockerComposeUp>("test") {
    doLast {
        // Get the docker logs from our nginx service.
        val outputStream = ByteArrayOutputStream()
        project.exec {
            commandLine = baseArguments + listOf("logs")
            standardOutput = outputStream
            workingDir = project.projectDir
        }
        val output = outputStream.toString()

        // See if the log has a match for the IP we set in the test.sh cURL -H command
        // Output is expected for follow the log_format specified in:
        //
        // nginx/rootfs/etc/confd/templates/nginx.conf.tmpl
        //
        // Which is:
        // log_format main '$remote_addr - $remote_user [$time_local] "$request" '
        //                 '$status $body_bytes_sent "$http_referer" '
        //                 '"$http_user_agent" "$http_x_forwarded_for"';
        // 
        //  A literal example:
        //
        // ::1 - - [14/Jul/2024:11:26:36 +0000] "GET / HTTP/1.1" 404 146 "-" "curl/8.5.0" "1.2.3.4"
        val logEntryPattern = """::1 - - \[\d{2}/[A-Za-z]{3}/\d{4}:\d{2}:\d{2}:\d{2} \+\d{4}\] "GET / HTTP/1\.1" \d{3} \d+ "-" "curl/\d+\.\d+\.\d+" "(?<ip>\d+\.\d+\.\d+\.\d+)"""".toRegex()

        val found = output.lines().any { logEntry ->
            logEntryPattern.find(logEntry)?.groups?.get("ip")?.value == "1.2.3.4"
        }

        // Fail the test if we didn't find any logs with the IP.
        if (!found) {
            throw GradleException("No log entry found where http_x_forwarded_for is set to 1.2.3.4")
        }
    }
}
