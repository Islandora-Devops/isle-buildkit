#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# `activemq status` only checks that a process with the recorded PID exists
# and looks like a `java` process (see `checkRunning` in bin/activemq); that
# is true almost immediately after the JVM is exec'd, long before the broker
# has finished starting and registered its shutdown hook. Waiting on that
# alone lets the test send SIGTERM before ActiveMQ can shut down gracefully,
# which failed intermittently once 6.3.x's larger Jetty 12 web console made
# startup slower. Poll the same Jolokia health check used by the image's own
# HEALTHCHECK instead, since "Good" there means the broker is fully up.
until curl -sf \
    -u "${ACTIVEMQ_WEB_ADMIN_NAME}:${ACTIVEMQ_WEB_ADMIN_PASSWORD}" \
    -H origin:localhost \
    "http://localhost:8161/api/jolokia/read/org.apache.activemq:type=Broker,brokerName=localhost,service=Health/CurrentStatus" \
    | grep -q Good
do
    echo "Waiting for ActiveMQ to successfully start"
    sleep 1
done

# All tests were successful
exit 0
