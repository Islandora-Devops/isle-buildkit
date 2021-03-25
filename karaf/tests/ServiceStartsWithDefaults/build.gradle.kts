import tasks.tests.ServiceStartsWithDefaultsTest
tasks.register<ServiceStartsWithDefaultsTest>("test") {
    waitForMessage.set("org.apache.karaf.features.core - 4.0.8 | Done")
}
