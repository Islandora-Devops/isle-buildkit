#!/usr/bin/with-contenv bash
set -e

# Transform the given string to uppercase.
function uppercase {
    local string="${1}"; shift
    echo $(tr '[:lower:]' '[:upper:]' <<< ${string})
}

# Get variable value for given site.
function matomo_site_env {
    local site="$(uppercase ${1})"; shift
    local suffix="$(uppercase ${1})"; shift
    var="MATOMO_SITE_${site}_${suffix}"
    echo "${!var}"
}

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

# Patch existing sites, which should only have a single row in the table.
# This is required to support multiple site configurations going forward.
function add_missing_column {
    cat <<- EOF
SET @database = DATABASE();

SELECT count(*)
INTO @exist
FROM information_schema.columns
WHERE table_schema = @database
and COLUMN_NAME = 'site'
AND table_name = 'matomo_site' LIMIT 1;

set @query = IF(@exist < 1, 'ALTER TABLE matomo_site ADD COLUMN site VARCHAR(255) NOT NULL UNIQUE AFTER idsite', 'select \'Column Exists\' status');
prepare stmt from @query;

EXECUTE stmt;
EOF
}

# Matomo only works with MySQL.
# https://github.com/matomo-org/matomo/issues/500
function update_query {
    cat <<- EOF
-- Update db user password.
SET PASSWORD FOR '${MATOMO_DB_USER}'@'%' = PASSWORD('${MATOMO_DB_PASSWORD}');

-- Update site name, host, timezone (idsite is hardcoded for the default site).
UPDATE matomo_site set
    site = 'DEFAULT',
    name = '${MATOMO_DEFAULT_SITE_NAME}',
    main_url = '${MATOMO_DEFAULT_SITE_HOST}',
    timezone = '${MATOMO_DEFAULT_SITE_TIMEZONE}'
    WHERE idsite = 1;

-- Update admin user password, email.
UPDATE matomo_user set
    password = '${MATOMO_USER_PASS}', 
    email = '${MATOMO_USER_EMAIL}'
    WHERE login = '${MATOMO_USER_NAME}';
EOF
}

function update_site_query {
    local site="$(uppercase ${1})"; shift
    local name=$(matomo_site_env "${site}" "NAME")
    local host=$(matomo_site_env "${site}" "HOST")
    local timezone=$(matomo_site_env "${site}" "TIMEZONE")
    cat <<- EOF
SET @site = '${site}',
    @name = '${name}',
    @host = '${host}',
    @timezone = '${timezone}';

-- Update or create row if 'site' already exists.
-- Default values come from 'create-matomo-database.sql.tmpl'.
INSERT INTO matomo_site (site, name, main_url, ts_created, ecommerce, sitesearch, sitesearch_keyword_parameters, sitesearch_category_parameters, timezone, currency, exclude_unknown_urls, excluded_ips, excluded_parameters, excluded_user_agents, \`group\`, type, keep_url_fragment, creator_login)
VALUES (@site, @name, @host, NOW(), 0, 1, '', '', @timezone, 'USD', 0, '', '', '', '', 'website', 0, 'anonymous')
ON DUPLICATE KEY UPDATE
    name = @name,
    main_url = @host,
    timezone = @timezone;
EOF
}

function update_database {
    echo "Updating Database: ${MATOMO_DB_NAME}"
    execute_sql_file --database ${MATOMO_DB_NAME} <(add_missing_column)
    execute_sql_file --database ${MATOMO_DB_NAME} <(update_query)
    for site in ${MATOMO_SITES}; do
        execute_sql_file --database ${MATOMO_DB_NAME} <(update_site_query "${site}")
    done
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
