import tasks.tests.ServiceStartsWithDefaultsTest
tasks.register<ServiceStartsWithDefaultsTest>("test") {
    // Uses `bdbje` backend by default.
    waitForMessage.set("INFO org.eclipse.jetty.server.Server - Started")
}
