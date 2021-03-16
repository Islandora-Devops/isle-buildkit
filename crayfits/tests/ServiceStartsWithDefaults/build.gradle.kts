import tasks.ServiceStartsWithDefaultsTestTask
tasks.register<ServiceStartsWithDefaultsTestTask>("test")  {
    waitForMessage.set("NOTICE: ready to handle connections")
}
