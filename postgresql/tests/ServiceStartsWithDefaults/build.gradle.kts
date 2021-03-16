import tasks.ServiceStartsWithDefaultsTestTask
tasks.register<ServiceStartsWithDefaultsTestTask>("test") {
    waitForMessage.set("database system is ready to accept connections")
}