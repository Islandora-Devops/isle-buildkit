#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

function count {
    cat <<-EOF | execute-sql-file.sh --database "fcrepo" - -- -N 2>/dev/null
SELECT COUNT(*) as count FROM containment;
EOF
}

# Wait for fcrepo to start.
for _ in {1..20}; do
    if curl --fail -s -u "${TOMCAT_ADMIN_NAME}:${TOMCAT_ADMIN_PASSWORD}" http://localhost:8080/fcrepo/rest &>/dev/null; then
        break
    fi
    sleep 1
done

curl --fail -s -u "${TOMCAT_ADMIN_NAME}:${TOMCAT_ADMIN_PASSWORD}" http://localhost:8080/fcrepo/rest >/dev/null

# Add some content.
old_count=$(count)
echo "Old Count: ${old_count}"
object=$(curl --fail -s -X POST -u "${TOMCAT_ADMIN_NAME}:${TOMCAT_ADMIN_PASSWORD}" -H "Content-Type:text/plain" "http://localhost:8080/fcrepo/rest")
echo "Create Object: $object"

# Check that the database has been modified.
new_count=$(count)
echo "New Count: ${new_count}"

# Check if results meet expectations.
if [[ "${new_count}" -gt "${old_count}" ]]; then
    echo "Database was modified."
else
    echo "Database was not modified."
    exit 1
fi

# All tests were successful
exit 0
