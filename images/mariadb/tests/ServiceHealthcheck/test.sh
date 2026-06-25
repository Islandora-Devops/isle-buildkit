#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC2329
on_terminate() {
    echo "Termination signal received. Exiting..."
    exit 0
}
trap 'on_terminate' SIGTERM

sleep 60

# The test runner should be stopping this container.
exit 1
