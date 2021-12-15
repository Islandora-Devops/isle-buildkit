import tasks.tests.ServiceStartsWithDefaultsTest
tasks.register<ServiceStartsWithDefaultsTest>("test")  {
    waitForMessage.set("NOTICE: ready to handle connections")
}
