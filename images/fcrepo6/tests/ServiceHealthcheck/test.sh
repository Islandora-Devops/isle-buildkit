#!/command/with-contenv bash
# shellcheck shell=bash

on_terminate() {
    echo "Termination signal received. Exiting..."
    exit 0
}
trap 'on_terminate' SIGTERM

sleep 60

# The kotlin check should be stopping this container
exit 1
