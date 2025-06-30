#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# Wait for service to start.
# We don't check if it is functioning as it requires a Transkribus account.
echo "Waiting for reponse on http://localhost:5000/"
while status=$(curl -s -w "%{http_code}" http://localhost:5000/ 2>/dev/null || echo "000") && [ "$status" != "400" ]; do
  sleep 5
done

# Service must start for us to get to this point.
exit 0
