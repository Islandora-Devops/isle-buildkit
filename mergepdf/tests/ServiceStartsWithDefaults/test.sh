#!/command/with-contenv bash
# shellcheck shell=bash

# Wait for service to start.
wait_20x http://localhost:8080/

# Service must start for us to get to this point.
exit 0
