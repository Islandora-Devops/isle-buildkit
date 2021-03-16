import tasks.ServiceStartsWithDefaultsTestTask
tasks.register<ServiceStartsWithDefaultsTestTask>("test") {
    waitForMessage.set("org.apache.catalina.startup.Catalina.start Server startup")
}
