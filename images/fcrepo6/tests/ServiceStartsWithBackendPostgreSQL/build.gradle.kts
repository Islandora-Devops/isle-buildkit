import plugins.TestsPlugin.DockerComposeUp

tasks.named<DockerComposeUp>("test") {
    // Remove 143 when https://github.com/Islandora-Devops/isle-buildkit/issues/269 is resolved.
    expectExitCodes("fcrepo6", 0)
}
