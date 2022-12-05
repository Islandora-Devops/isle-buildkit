import java.time.Duration.ofMinutes
import plugins.TestPlugin.DockerComposeUp

tasks.named<DockerComposeUp>("test") {
    // This test requires more time that normal.
    timeout.convention(ofMinutes(10))
}
