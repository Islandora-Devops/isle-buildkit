import plugins.TestPlugin.DockerComposeUp

tasks.named<DockerComposeUp>("test") {
    expectOutput("alpaca", "[main] (AlpacaDriver) Alpaca started")
}
