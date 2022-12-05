#!/command/with-contenv bash
# shellcheck shell=bash
set -e

# Creates database / user if not already exists. This needs to be seperated as
# we cannot use 'User Defined' variables to select database/tables.
function create_database {
    cat <<-EOF | create-database.sh
-- Create matomo database in mariadb or mysql.
CREATE DATABASE IF NOT EXISTS ${MATOMO_DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Create matomo_user and grant rights.
CREATE USER IF NOT EXISTS ${MATOMO_DB_USER}@'%' IDENTIFIED BY "${MATOMO_DB_PASSWORD}";
GRANT ALL PRIVILEGES ON ${MATOMO_DB_NAME}.* to ${MATOMO_DB_USER}@'%';
FLUSH PRIVILEGES;
EOF
}

function database_exists {
    cat <<-EOF | execute-sql-file.sh
USE '${MATOMO_DB_NAME}';
EOF
}

function created_database {
    if ! database_exists; then
        echo "Creating database: ${MATOMO_DB_NAME}"
        create_database
    else
        echo "Database: ${MATOMO_DB_NAME} already exists"
    fi
}

function main {
    created_database
}
main
