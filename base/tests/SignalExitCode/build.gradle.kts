import tasks.DockerCompose
tasks.register<DockerCompose>("test") {
    doFirst {
        setUp()
        up("--abort-on-container-exit", ignoreExitValue = true)
        tearDown() // Sends SIGTERM container should recieve it and exit gracefully.
        info.get()["base"]!!.let { info ->
            val state = info.state
            if (state.exitCodeLong != 130L) { // 128 + 2 (SIGINT) == 130
                throw RuntimeException("Container $name exited with ${state.exitCodeLong} and status ${state.status}.")
            }
        }
    }
}
