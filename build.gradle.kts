plugins {
  id("io.github.nigelgbanks.Isle") version "1.0.1"
}

// Include any folder that has a Dockerfile as a sub-project.
val loadTasks = rootProject.projectDir
    .walk()
    .maxDepth(1) // Only immediate directories.
    .filter { it.isDirectory && it.resolve("Dockerfile").exists() } // Must have a Dockerfile.
    .map { directory ->
        // Include as a sub-project.
        directory.relativeTo(rootProject.projectDir).path + ":load"
    }.toList().toTypedArray()

val down by tasks.registering(Exec::class) {
    commandLine("docker", "compose", "down", "-v")
}

val wait by tasks.registering(Exec::class) {
    commandLine(
        "docker",
        "compose",
        "exec",
        "drupal",
        "timeout",
        "600",
        "bash",
        "-c",
        "while ! test -f /installed; do sleep 5; done"
    )
    doLast {
        logger.quiet(
            """
            For all services the credentials are:

            Username: admin
            Password: password

            The following services can be reached at the given URLs:

            ActiveMQ: https://activemq.islandora.dev/
            Blazegraph: https://blazegraph.islandora.dev/bigdata/
            Drupal: https://islandora.dev/
            Fedora: https://fcrepo.islandora.dev/fcrepo/rest/
            Matomo: https://islandora.dev/matomo/index.php
            Solr: https://solr.islandora.dev/solr/#/
            Traefik: https://traefik.islandora.dev/dashboard/#/
            """.trimIndent()
        )
    }
}

tasks.register<Exec>("up") {
    commandLine("docker", "compose", "up", "-d")
    dependsOn(":generateCertificates", *loadTasks)
    mustRunAfter(down)
    finalizedBy(wait)
}
