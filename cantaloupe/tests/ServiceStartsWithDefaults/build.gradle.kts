import tasks.tests.ServiceStartsWithDefaultsTest
tasks.register<ServiceStartsWithDefaultsTest>("test") {
    waitForMessage.set("org.apache.catalina.startup.Catalina.start Server startup")
}
