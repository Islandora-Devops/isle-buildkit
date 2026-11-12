#!/command/with-contenv bash
# shellcheck shell=bash

set -eou pipefail

# Wait for Nginx to be ready.
s6-svwait -U /run/service/nginx

# Match the trusted IPv4 proxy configured by this test, regardless of DNS order.
curl -s -o /dev/null -H "X-Forwarded-For: 1.2.3.4" http://127.0.0.1:80/

# Service must start for us to get to this point.
exit 0
