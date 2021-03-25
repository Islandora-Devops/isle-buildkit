import java.time.Duration.ofMinutes
import tasks.tests.DockerComposeTest

tasks.register<DockerComposeTest>("test") {
    timeout.convention(ofMinutes(10))
}