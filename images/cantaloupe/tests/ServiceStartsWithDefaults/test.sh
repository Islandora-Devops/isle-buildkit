#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

wait_20x "http://localhost:8182"

# Service must start for us to get to this point.
exit 0
