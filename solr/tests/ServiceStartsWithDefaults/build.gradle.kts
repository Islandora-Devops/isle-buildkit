import tasks.tests.ServiceStartsWithDefaultsTest
tasks.register<ServiceStartsWithDefaultsTest>("test") {
    waitForMessage.set("o.e.j.s.Server Started")
}
