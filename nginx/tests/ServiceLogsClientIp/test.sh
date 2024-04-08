#!/command/with-contenv bash
# shellcheck shell=bash

set -eou pipefail

# Wait for Nginx to be ready.
s6-svwait -U /run/service/nginx

# hit localhost nginx with the proper header so that IP is logged
curl -s -o /dev/null -H "X-Forwarded-For: 1.2.3.4" http://localhost:80/

# Service must start for us to get to this point.
exit 0
