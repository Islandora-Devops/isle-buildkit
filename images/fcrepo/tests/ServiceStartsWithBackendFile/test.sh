#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# Wait for fcrepo to start.
wait_20x http://localhost:8080/fcrepo/rest

# Add some content.
object=$(curl --fail -s -X POST -H "Authorization: Bearer ${JWT_ADMIN_TOKEN}" -H "Content-Type:text/plain" "http://localhost:8080/fcrepo/rest")
echo "Create Object: $object"

# All tests were successful
exit 0
