#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# Wait for service to start.
wait_20x http://localhost:8080/fits

# Service must start for us to get to this point.
exit 0
