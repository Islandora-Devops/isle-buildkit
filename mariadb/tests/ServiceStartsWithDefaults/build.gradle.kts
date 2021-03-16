import tasks.ServiceStartsWithDefaultsTestTask
tasks.register<ServiceStartsWithDefaultsTestTask>("test") {
    waitForMessage.set("mysqld: ready for connections.")
}
