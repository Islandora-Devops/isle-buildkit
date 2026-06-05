#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

until /opt/activemq/bin/activemq status
do
    echo "Waiting for ActiveMQ to successfully start"
    sleep 1
done

if ! bash -c "</dev/tcp/localhost/61613"; then
    echo "ActiveMQ STOMP connector is not listening on port 61613"
    exit 1
fi

# All tests were successful
exit 0
