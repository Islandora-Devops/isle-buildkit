import tasks.tests.ServiceStartsWithDefaultsTest
tasks.register<ServiceStartsWithDefaultsTest>("test") {
    waitForMessage.set("INFO: Lock acquired")
}
