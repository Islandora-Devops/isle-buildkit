#!/usr/bin/with-contenv bash

source /usr/local/share/isle/utilities.sh

# Exit non-zero if database does not exist.
cat <<- EOF | execute-sql-file.sh
use ${DB_NAME}
EOF

# All tests were successful
exit 0
