import plugins.TestsPlugin.DockerComposeUp
import plugins.TestsPlugin.DockerComposeUp.Companion.pool
import java.lang.Thread.sleep
import java.time.Duration.ofSeconds
import java.util.concurrent.CompletableFuture.supplyAsync

tasks.named<DockerComposeUp>("test") {
    expectExitCode("base", 137) // 128 + 9 SIGKILL (Bash script does not catch signal)
    doFirst {
        supplyAsync(
            {
                // Send TERM after 10 seconds externally.
                sleep(ofSeconds(10).toMillis())
                project.exec {
                    workingDir = projectDir
                    commandLine = baseArguments + listOf("stop")
                }
            }, pool
        )
    }
}
