import plugins.TestsPlugin.DockerComposeUp

tasks.named<DockerComposeUp>("test") {
    expectExitCodes("houdini", 0)
}
