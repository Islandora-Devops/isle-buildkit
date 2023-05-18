import plugins.TestsPlugin.DockerComposeUp

tasks.named<DockerComposeUp>("test") {
    expectExitCode("base", 15) // 15 (SIGTERM) handled by the test service.
}
