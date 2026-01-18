import plugins.TestsPlugin.DockerComposeUp

tasks.named<DockerComposeUp>("test") {
    expectExitCode("base", 143) // 128 + 15 (SIGTERM) == 143
}
