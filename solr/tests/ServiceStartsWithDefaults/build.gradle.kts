import tasks.ServiceStartsWithDefaultsTestTask
tasks.register<ServiceStartsWithDefaultsTestTask>("test") {
    waitForMessage.set("o.e.j.s.Server Started")
}
