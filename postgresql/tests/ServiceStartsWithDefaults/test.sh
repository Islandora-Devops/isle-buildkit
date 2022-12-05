#!/command/with-contenv bash
# shellcheck shell=bash

if timeout 300 wait-for-open-port.sh "localhost" "5432"; then
    echo "Service Started"
    exit 0
else
    echo "Service failed to start"
    exit 1
fi
