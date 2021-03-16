package tasks

import com.github.dockerjava.api.async.ResultCallback
import com.github.dockerjava.api.command.InspectContainerResponse.ContainerState
import com.github.dockerjava.api.exception.NotFoundException
import com.github.dockerjava.api.exception.NotModifiedException
import com.github.dockerjava.api.model.Frame
import org.gradle.api.tasks.*
import org.gradle.kotlin.dsl.property
import java.time.Duration
import java.time.Instant
import java.time.format.DateTimeFormatter
import kotlin.concurrent.thread

@Suppress("UnstableApiUsage")
abstract class DockerContainerTask : DockerClientTask() {

    // Not marked as input as the tag can change but the image contents may be the same so we do not want to rerun.
    @Internal
    val imageId = project.objects.property<String>().convention(defaultImageId())

    // Not actually the image digest but rather an approximation that ignores timestamps, etc.
    // So we do not run test unless the image has actually changed.
    @InputFile
    @PathSensitive(PathSensitivity.RELATIVE)
    val approximateImageDigest =
        project.objects.fileProperty().convention(defaultApproximateImageDigestTask().map { it.digest.get() })

    // Capture the log output of the command for later inspection.
    @OutputFile
    val log = project.objects.fileProperty().convention(project.layout.buildDirectory.file("${name}.log"))

    // Identifier of the container started to run this task.
    @Suppress("ANNOTATION_TARGETS_NON_EXISTENT_ACCESSOR")
    @get:Internal
    protected val containerId = project.objects.property<String>()

    @Internal
    val state = project.objects.property<ContainerState>()

    init {
        // By default limit max execution time to a minute.
        timeout.convention(Duration.ofMinutes(5))
        // Ensure we do not leave container running if something goes wrong.
        project.gradle.buildFinished {
            // May be called before creation of container if build is cancelled etc.
            if (containerId.isPresent) {
                remove()
            }
        }
    }

    // To be able to update the log and view after completion we need it on a separate thread.
    private val loggingThread by lazy {
        thread(start = false) {
            log.get().asFile.bufferedWriter().use { writer ->
                dockerClient.logContainerCmd(containerId.get())
                    .withFollowStream(true)
                    .withStdOut(true)
                    .withStdErr(true)
                    .exec(object : ResultCallback.Adapter<Frame>() {
                        override fun onNext(frame: Frame) {
                            val timestamp = DateTimeFormatter.ISO_INSTANT.format(Instant.now())
                            val payload = String(frame.payload).trim { it <= ' ' }
                            val line = "[$timestamp] ${frame.streamType}: $payload"
                            logger.info(line)
                            writer.write("$line\n")
                        }
                    }).awaitCompletion()
            }
        }
    }

    private fun create() = containerId.set(dockerClient.createContainerCmd(imageId.get()).exec().id)

    private fun start() = dockerClient.startContainerCmd(containerId.get()).exec()

    private fun stop() = try {
        dockerClient.stopContainerCmd(containerId.get()).exec()
    } catch (e: NotModifiedException) {
        // Ignore if not modified, as it has already been stopped.
    } catch (e: Exception) {
        // Unrecoverable error, user will have to clean up their environment.
        throw e
    }

    private fun inspect() = dockerClient.inspectContainerCmd(containerId.get()).exec()

    private fun remove() = try {
        dockerClient
            .removeContainerCmd(containerId.get())
            .withForce(true)
            .exec()
    } catch (e: NotFoundException) {
        // Ignore if not found, as it has already been removed.
    } catch (e: Exception) {
        // Unrecoverable error, user will have to clean up their environment.
        throw e
    }

    // Executes callback for each line of log output until the stream ends or the callback returns false.
    protected fun untilOutput(callback: (String) -> Boolean) {
        dockerClient.logContainerCmd(containerId.get())
            .withTailAll()
            .withFollowStream(true)
            .withStdOut(true)
            .withStdErr(true)
            .exec(object : ResultCallback.Adapter<Frame>() {
                override fun onNext(frame: Frame) {
                    val line = String(frame.payload)
                    if (!callback(line)) {
                        close()
                    }
                    super.onNext(frame)
                }
            })?.awaitCompletion()
    }

    protected fun setUp() {
        create()
        start()
        loggingThread.start()
    }

    protected fun tearDown() {
        stop()
        loggingThread.join()
        inspect().let { response ->
            state.set(response.state)
        }
        remove()
    }
}