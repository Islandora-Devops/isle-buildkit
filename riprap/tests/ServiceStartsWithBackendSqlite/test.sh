#!/usr/bin/with-contenv bash

source /usr/local/share/isle/utilities.sh

# Perform check-fixity (ingests from CSV).
check-fixity.sh "--settings=/var/www/riprap/cron_config.yaml"

# Confirm sqlite database exists.
test -e /var/www/riprap/var/data.db

# Query the database to determine if the expected number of checks occured.
rows=$(
cat <<'EOF' | php -f /dev/stdin
<?php
$db  = new PDO('sqlite:/var/www/riprap/var/data.db');
$sql = "SELECT COUNT(*) as count FROM fixity_check_event";
$result = $db->query($sql);
if($result){
    while($row = $result->fetch(PDO::FETCH_ASSOC)){
        echo $row['count'];
    }
}
?>
EOF
)

# Check if results meet expectations.
if [[ "${rows}" != "3" ]]; then
    echo "Failed to created the expected number of rows: ${rows}!=3."
    exit 1
else
    echo "Created the expected number of rows."
fi

# All tests were successful
exit 0