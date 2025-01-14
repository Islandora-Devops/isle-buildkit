#!/command/with-contenv bash
# shellcheck shell=bash

on_terminate() {
    echo "Termination signal received. Exiting..."
    exit 0
}
trap 'on_terminate' SIGTERM

# Wait for Nginx to be ready.
s6-svwait -U /run/service/nginx

sleep 60

# Service must start for us to get to this point.
exit 1
