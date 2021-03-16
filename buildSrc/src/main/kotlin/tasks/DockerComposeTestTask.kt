package tasks

import org.gradle.api.tasks.CacheableTask
import org.gradle.api.tasks.TaskAction

@CacheableTask
open class DockerComposeTestTask : DockerComposeTask() {

    @TaskAction
    fun exec() {
        setUp()
        up("--abort-on-container-exit")
        tearDown()
        // Check if any of the containers exited non-zero.
        states.get().forEach { (name, state) ->
            if (state.exitCodeLong != 0L) {
                throw RuntimeException("Container $name exited with ${state.exitCodeLong} and status ${state.status}.")
            }
        }

    }
}