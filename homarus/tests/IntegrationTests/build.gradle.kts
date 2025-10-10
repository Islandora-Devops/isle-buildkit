import plugins.TestsPlugin.DockerComposeUp

tasks.named<DockerComposeUp>("test") {
    expectExitCodes("homarus", 0)
}
