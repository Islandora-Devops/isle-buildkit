import plugins.TestsPlugin.DockerCompose
import tasks.DockerPull

val pull by tasks.registering(DockerPull::class) {
    image.set("gcr.io/etcd-development/etcd:v3.5.6")
}

tasks.named<DockerCompose>("setUp") {
    doLast {
        project.exec {
            commandLine = baseArguments + listOf("up", "-d", "etcd")
            workingDir = project.projectDir
        }
        project.exec {
            commandLine = baseArguments + listOf("exec", "-T", "etcd", "sh", "/populate-etcd.sh")
            workingDir = project.projectDir
        }
    }
    dependsOn(pull)
}
