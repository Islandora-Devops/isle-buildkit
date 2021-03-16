import tasks.ServiceStartsWithDefaultsTestTask
tasks.register<ServiceStartsWithDefaultsTestTask>("test") {
    // Uses `bdbje` backend by default.
    waitForMessage.set("INFO org.eclipse.jetty.server.Server - Started")
}
