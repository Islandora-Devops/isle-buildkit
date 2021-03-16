#!/usr/bin/with-contenv bash

source /usr/local/share/isle/utilities.sh
count=$(execute-sql-file.sh <(echo "SELECT 1 FROM pg_database WHERE datname='gemini'") -- --csv -t)

if [[ "${count}" -eq "1" ]]; then
    echo "Database exists."
else
    echo "Database missing."
    exit 1
fi

# All tests were successful
exit 0
