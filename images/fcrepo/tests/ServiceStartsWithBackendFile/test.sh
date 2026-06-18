#!/command/with-contenv bash
# shellcheck shell=bash

# Wait for fcrepo to start.
for _ in {1..20}; do
    if curl --fail -s -u "${TOMCAT_ADMIN_NAME}:${TOMCAT_ADMIN_PASSWORD}" http://localhost:8080/fcrepo/rest &>/dev/null; then
        break
    fi
    sleep 1
done

curl --fail -s -u "${TOMCAT_ADMIN_NAME}:${TOMCAT_ADMIN_PASSWORD}" http://localhost:8080/fcrepo/rest >/dev/null

# Add some content.
object=$(curl --fail -s -X POST -u "${TOMCAT_ADMIN_NAME}:${TOMCAT_ADMIN_PASSWORD}" -H "Content-Type:text/plain" "http://localhost:8080/fcrepo/rest")
echo "Create Object: $object"

# All tests were successful
exit 0
