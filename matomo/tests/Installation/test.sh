#!/command/with-contenv bash
# shellcheck shell=bash
set -e

# Run diagnostics, ignore warnings.
echo "Running diagnostics."
cd /var/www/matomo
./console diagnostics:run --ignore-warn

# All tests were successful
exit 0
