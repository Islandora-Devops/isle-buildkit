#!/command/with-contenv bash
# shellcheck shell=bash

set -x

# Wait for Nginx to be ready.
s6-svwait -U /run/service/nginx

# Service must start for us to get to this point.
exit 0
