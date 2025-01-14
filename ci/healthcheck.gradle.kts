import plugins.TestsPlugin.DockerComposeUp
import plugins.TestsPlugin.DockerComposeUp.Companion.pool
import java.lang.Thread.sleep
import java.time.Duration.ofSeconds
import java.util.concurrent.CompletableFuture.supplyAsync
import java.io.ByteArrayOutputStream

tasks.named<DockerComposeUp>("test") {
    doFirst {
        supplyAsync(
            {
                val maxAttempts = 10
                val delayBetweenAttempts = 5000L // 5 seconds in milliseconds
                var attempt = 0
                var foundHealthyService = false

                while (attempt < maxAttempts) {
                    attempt++
                    val outputStream = ByteArrayOutputStream()
                    project.exec {
                        commandLine = baseArguments + listOf("ps", "--all")
                        standardOutput = outputStream
                        workingDir = project.projectDir
                    }
                    val output = outputStream.toString()

                    val healthyServicePattern = """(?m)^.+\s+.+\s+Up \d+ seconds \(healthy\).*$""".toRegex()
                    foundHealthyService = output.lines().any { line ->
                        healthyServicePattern.matches(line)
                    }

                    if (foundHealthyService) {
                        println("Service is healthy. Exiting test...")
                        project.exec {
                            commandLine = baseArguments + listOf("stop")
                            standardOutput = outputStream
                            workingDir = project.projectDir
                        }
                        break
                    }

                    if (attempt < maxAttempts) {
                        println("No healthy service found. Retrying in ${delayBetweenAttempts / 1000} seconds...")
                        sleep(delayBetweenAttempts)
                    }
                }

                // Throw an exception if no healthy service was found after all attempts
                if (!foundHealthyService) {
                    throw GradleException("No service is marked as healthy in docker compose ps output after $maxAttempts attempts.")
                }
            }, pool
        )
    }
}
