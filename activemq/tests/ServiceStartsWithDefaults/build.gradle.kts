import tasks.ServiceStartsWithDefaultsTestTask
tasks.register<ServiceStartsWithDefaultsTestTask>("test") {
    waitForMessage.set("started | org.apache.activemq.broker.BrokerService")
}
