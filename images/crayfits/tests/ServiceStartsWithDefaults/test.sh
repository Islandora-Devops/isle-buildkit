#!/command/with-contenv bash
# shellcheck shell=bash

set -x

wait_20x "http://localhost:8000/"

# Service must start for us to get to this point.
exit 0
