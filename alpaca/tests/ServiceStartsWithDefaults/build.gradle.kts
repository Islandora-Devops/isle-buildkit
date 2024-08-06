import plugins.TestsPlugin.DockerComposeUp

tasks.named<DockerComposeUp>("test") {
    expectExitCodes("alpaca", 0)
    expectOutput("alpaca", "[main] (AlpacaDriver) Alpaca started")
}
