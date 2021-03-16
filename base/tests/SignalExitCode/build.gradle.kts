import tasks.DockerComposeTask
tasks.register<DockerComposeTask>("test") {
    doFirst {
        setUp()
        up("--abort-on-container-exit", ignoreExitValue = true)
        tearDown()
        states.get()["base"]!!.let { state ->
            // 128 + 15 (SIGTERM) == 143
            if (state.exitCodeLong != 143L) {
                throw RuntimeException("Container $name exited with ${state.exitCodeLong} and status ${state.status}.")
            }
        }
    }
}
