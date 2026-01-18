#!/command/with-contenv bash
# shellcheck shell=bash

wait_20x "http://localhost:8000/"

# Service must start for us to get to this point.
exit 0
