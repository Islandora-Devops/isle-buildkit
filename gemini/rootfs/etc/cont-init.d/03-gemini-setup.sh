#!/usr/bin/with-contenv bash
set -e

function execute_sql_file {
    execute-sql-file.sh \
        --driver "${GEMINI_DB_DRIVER}" \
        --host "${GEMINI_DB_HOST}" \
        --port "${GEMINI_DB_PORT}" \
        --user "${GEMINI_DB_ROOT_USER}" \
        --password "${GEMINI_DB_ROOT_PASSWORD}" \
        "${@}"
}

function mysql_query {
    cat <<- EOF
-- Create gemini database in mariadb or mysql. 
CREATE DATABASE IF NOT EXISTS ${GEMINI_DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE IF NOT EXISTS ${GEMINI_DB_NAME}.Gemini (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    drupal VARCHAR(2048) NOT NULL UNIQUE,
    fedora VARCHAR(2048) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Create gemini user and grant rights.
CREATE USER IF NOT EXISTS '${GEMINI_DB_USER}'@'%' IDENTIFIED BY '${GEMINI_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${GEMINI_DB_NAME}.* to '${GEMINI_DB_USER}'@'%';
FLUSH PRIVILEGES;

-- Update gemini user password if changed.
SET PASSWORD FOR ${GEMINI_DB_USER}@'%' = PASSWORD('${GEMINI_DB_PASSWORD}')
EOF
}

function mysql_create_database {
    execute_sql_file <(mysql_query)
}

function postgres_query {
    cat <<- EOF
BEGIN;

DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${GEMINI_DB_USER}') THEN
        CREATE ROLE ${GEMINI_DB_USER};
    END IF;
END
\$\$;

ALTER ROLE ${GEMINI_DB_USER} WITH LOGIN;
ALTER USER ${GEMINI_DB_USER} PASSWORD '${GEMINI_DB_PASSWORD}';

ALTER DATABASE ${GEMINI_DB_NAME} OWNER TO ${GEMINI_DB_USER};
GRANT ALL PRIVILEGES ON DATABASE ${GEMINI_DB_NAME} TO ${GEMINI_DB_USER};

CREATE TABLE IF NOT EXISTS
Gemini (
  id SERIAL PRIMARY KEY,
  drupal VARCHAR(2048) NOT NULL UNIQUE,
  fedora VARCHAR(2048) NOT NULL UNIQUE
);
ALTER TABLE Gemini OWNER TO ${GEMINI_DB_USER};

COMMIT;
EOF
}

function postgresql_database_exists {
    execute_sql_file --database "${GEMINI_DB_NAME}" <(echo 'select 1')
}

function postgresql_create_database {
    # Postgres does not support CREATE DATABASE IF NOT EXISTS so split our logic across multiple queries.
    if ! postgresql_database_exists; then
        execute_sql_file <(echo "CREATE DATABASE ${GEMINI_DB_NAME}")
    fi
    execute_sql_file --database "${GEMINI_DB_NAME}" <(postgres_query)
}

function create_database {
    case "${GEMINI_DB_DRIVER}" in
        mysql|pdo_mysql)
            mysql_create_database
            ;;
        pgsql|postgresql|pdo_pgsql)
            postgresql_create_database
            ;;
        *)
            echo "Only MySQL/PostgresSQL databases are supported for now." >&2
            exit 1
    esac
}

function run_migrations {
    php bin/console --no-interaction migrations:migrate
}

function main {
    create_database
    run_migrations
}
main
