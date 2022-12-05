import plugins.TestPlugin.DockerComposeUp

tasks.named<DockerComposeUp>("test") {
    expectExitCode("base", 130) // 128 + 2 (SIGINT) == 130
}
