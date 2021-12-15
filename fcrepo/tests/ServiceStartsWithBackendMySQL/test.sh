#!/usr/bin/with-contenv bash

source /usr/local/share/isle/utilities.sh

function count {
    cat <<- EOF | execute-sql-file.sh --database "fcrepo" - -- -N 2>/dev/null
SELECT COUNT(ID) as count FROM MODESHAPE_REPOSITORY;
EOF
}

# Wait for fcrepo to start.
wait_20x http://localhost:8080/fcrepo/rest

# Add some content.
old_count=$(count)
echo "Old Count: ${old_count}"
object=$(curl --fail -X POST -H "Authorization: Bearer islandora" -H "Content-Type:text/plain" "http://localhost/fcrepo/rest" 2>/dev/null)
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