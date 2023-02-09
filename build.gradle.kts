import plugins.BuildPlugin.Companion.isleBuildTags
import plugins.IslePlugin.Companion.isDockerProject


apply(plugin = "io.github.nigelgbanks.Isle")

val down by tasks.registering(Exec::class) {
    group = "Isle"
    description = "Stops test docker compose environment and removes volumes"
    commandLine("docker", "compose", "down", "-v")
}

val wait by tasks.registering(Exec::class) {
    group = "Isle"
    description = "Waits for test image to successfully install Drupal"
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

// Include any folder that has a Dockerfile as a sub-project.
val buildTasks = rootProject.projectDir
    .walk()
    .maxDepth(1) // Only immediate directories.
    .filter { it.isDirectory && it.resolve("Dockerfile").exists() } // Must have a Dockerfile.
    .map { directory ->
        // Include as a sub-project.
        directory.relativeTo(rootProject.projectDir).path + ":build"
    }.toList().toTypedArray()

tasks.register<Exec>("up") {
    group = "Isle"
    description = "Starts test docker compose environment"
    commandLine("docker", "compose", "up", "-d")
    dependsOn(":generateCertificates", buildTasks)
    mustRunAfter(down)
    finalizedBy(wait)
}
