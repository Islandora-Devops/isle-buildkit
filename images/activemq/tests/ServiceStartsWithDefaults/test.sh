#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

until /opt/activemq/bin/activemq status
do
    echo "Waiting for ActiveMQ to successfully start"
    sleep 1
done

# All tests were successful
exit 0
