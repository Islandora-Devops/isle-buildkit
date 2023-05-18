#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

function count {
    cat <<-EOF | execute-sql-file.sh --database "${DB_NAME}" - -- -N 2>/dev/null
SELECT COUNT(*) as count FROM fixity_check_event;
EOF
}

# Exit non-zero if database does not exist.
cat <<-EOF | execute-sql-file.sh
	use ${DB_NAME}
EOF

# Perform check-fixity (ingests from CSV).
check-fixity.sh "--settings=/var/www/riprap/cron_config.yaml"

# Query the database to determine if the expected number of checks occured.
rows=$(count)

# Check if results meet expectations.
if [[ "${rows}" != "3" ]]; then
    echo "Failed to created the expected number of rows: ${rows}!=3."
    exit 1
else
    echo "Created the expected number of rows."
fi

# All tests were successful
exit 0
