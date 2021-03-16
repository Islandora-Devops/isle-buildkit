import tasks.DockerComposeTask
tasks.register<DockerComposeTask>("test") {
    doFirst {
        setUp()
        up("--abort-on-container-exit", ignoreExitValue = true)
        tearDown()
        // Check if any of the containers exited with the same value as the failed service.
        states.get()["base"]!!.let { state ->
            if (state.exitCodeLong != 11L) {
                throw RuntimeException("Container base exited with ${state.exitCodeLong} and status ${state.status}.")
            }
        }
    }
}
