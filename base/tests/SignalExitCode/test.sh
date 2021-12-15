#!/usr/bin/with-contenv bash

s6-svc -i /var/run/s6/services/test
echo "[services.d] Send SIGINT to test service." >&2
sleep 100000
