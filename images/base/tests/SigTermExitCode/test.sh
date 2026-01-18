#!/command/with-contenv bash
# shellcheck shell=bash

sleep 10
echo "s6-rc: info: Send SIGINT to confd service." >&2
s6-svc -t /run/s6/legacy-services/test

echo "s6-rc: info: Waiting for exit." >&2
sleep 100000
