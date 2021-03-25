import tasks.DockerCompose
tasks.register<DockerCompose>("test") {
    doFirst {
        setUp()
        up("--abort-on-container-exit", ignoreExitValue = true)
        tearDown()
        // Check if any of the containers exited with the same value as the failed service.
        info.get()["base"]!!.let { info ->
            val state = info.state
            if (state.exitCodeLong != 11L) {
                throw RuntimeException("Container base exited with ${state.exitCodeLong} and status ${state.status}.")
            }
        }
    }
}
