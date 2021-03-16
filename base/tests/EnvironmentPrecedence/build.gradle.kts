@file:Suppress("UnstableApiUsage")

import org.gradle.nativeplatform.platform.internal.DefaultNativePlatform
import java.io.ByteArrayOutputStream
import java.time.Duration.ofSeconds
import tasks.DockerComposeTask
import java.lang.RuntimeException

tasks.register<DockerComposeTask>("test") {
    val arch = DefaultNativePlatform.getCurrentArchitecture()!!
    timeout.convention(ofSeconds(30))
    environment.put("ETCD_TAG", if (arch.isArm) "gcr.io/etcd-development/etcd:v3.4.15-arm64" else "gcr.io/etcd-development/etcd:v3.4.15")
    doFirst {
        setUp()
        // Populate etcd before starting other containers.
        up("-d", "etcd")
        exec("-T", "etcd", "sh", "/populate-etcd.sh")
        up( "--abort-on-container-exit") // Run test.sh as a CMD service and blocking until completion or failure.
        tearDown()
        // Check if any of the containers exited non-zero.
        states.get().forEach { (name, state) ->
            if (state.exitCodeLong != 0L) {
                throw RuntimeException("Container $name exited with ${state.exitCodeLong} and status ${state.status}.")
            }
        }
    }

}