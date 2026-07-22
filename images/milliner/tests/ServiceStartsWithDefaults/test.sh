#!/command/with-contenv bash
# shellcheck shell=bash

# Wait for PHP-FPM to start.
wait_20x http://localhost/status

# Confirm that the Symfony application handles a request. Milliner has no root route.
# shellcheck disable=SC2034 # Read indirectly by expect.
status=$(curl --silent --output /dev/null --write-out '%{http_code}' http://localhost:8000/)
expect status 404

# Service must start for us to get to this point.
exit 0
