import plugins.TestPlugin.DockerComposeUp

tasks.named<DockerComposeUp>("test") {
    expectOutput("base", "service confd successfully started")
}
