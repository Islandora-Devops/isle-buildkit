import plugins.TestsPlugin.DockerComposeUp

tasks.named<DockerComposeUp>("test") {
    expectExitCodes("hypercube", 0)
}
