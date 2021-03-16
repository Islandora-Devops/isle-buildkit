import java.time.Duration.ofMinutes
import tasks.DockerComposeTestTask

tasks.register<DockerComposeTestTask>("test") {
    timeout.convention(ofMinutes(10))
}