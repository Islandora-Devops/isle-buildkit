import tasks.tests.ServiceStartsWithDefaultsTest
tasks.register<ServiceStartsWithDefaultsTest>("test") {
    waitForMessage.set("database system is ready to accept connections")
}