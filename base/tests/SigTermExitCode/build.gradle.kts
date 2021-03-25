import tasks.DockerCompose
tasks.register<DockerCompose>("test") {
    doFirst {
        setUp()
        up("--abort-on-container-exit", ignoreExitValue = true)
        tearDown()
        info.get()["base"]!!.let { info ->
            val state = info.state
            if (state.exitCodeLong != 0L) {
                throw RuntimeException("Container $name exited with ${state.exitCodeLong} and status ${state.status}.")
            }
        }
    }
}
