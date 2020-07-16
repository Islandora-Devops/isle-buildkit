#!/usr/bin/with-contenv bash
set -e

function execute_sql_file {
    # Matomo only works with MySQL.
    # https://github.com/matomo-org/matomo/issues/500
    execute-sql-file.sh \
        --driver "${MATOMO_DB_DRIVER}" \
        --host "${MATOMO_DB_HOST}" \
        --port "${MATOMO_DB_PORT}" \
        --user "${MATOMO_DB_ROOT_USER}" \
        --password "${MATOMO_DB_ROOT_PASSWORD}" \
        "${@}"
}

# Matomo only works with MySQL.
# https://github.com/matomo-org/matomo/issues/500
function update_query {
    cat <<- EOF
-- Update db user password.
SET PASSWORD FOR '${MATOMO_DB_USER}'@'%' = PASSWORD('${MATOMO_DB_PASSWORD}');

-- Update site name, host, timezone.
UPDATE matomo_site set
    name = '${MATOMO_SITE_NAME}',
    main_url = '${MATOMO_SITE_HOST}',
    timezone = '${MATOMO_SITE_TIMEZONE}'
    WHERE idsite = 1;

-- Update admin user password, email.
UPDATE matomo_user set
    password = '${MATOMO_USER_PASS}', 
    email = '${MATOMO_USER_EMAIL}'
    WHERE login = '${MATOMO_USER_NAME}';
EOF
}

function update_database {
    echo "Updating Database: ${MATOMO_DB_NAME}"
    execute_sql_file --database ${MATOMO_DB_NAME} <(update_query)
}

function exists_query {
    cat <<- EOF
USE '${MATOMO_DB_NAME}';
EOF
}

function created_database {
    if ! execute_sql_file <(exists_query); then
        # File is created from a confd template.
        echo "Creating database: ${MATOMO_DB_NAME}"
        execute_sql_file /var/run/islandora/create-matomo-database.sql
    else
        echo "Database: ${MATOMO_DB_NAME} already exists"
    fi
}

function main {
    created_database
    update_database
}
main
