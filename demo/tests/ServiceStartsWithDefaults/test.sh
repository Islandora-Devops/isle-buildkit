#!/usr/bin/with-contenv bash

source /usr/local/share/isle/utilities.sh

# Exit non-zero if database does not exist.
cat <<- EOF | execute-sql-file.sh
use ${DB_NAME}
EOF

# Wait for Drupal to start.
wait_20x http://localhost:80/

# All tests were successful
exit 0