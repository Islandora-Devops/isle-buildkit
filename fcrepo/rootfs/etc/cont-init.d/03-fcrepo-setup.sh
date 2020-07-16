#!/usr/bin/with-contenv bash
set -e

function execute_sql_file {
    execute-sql-file.sh \
        --driver "${FCREPO_PERSISTENCE_TYPE}" \
        --host "${FCREPO_DB_HOST}" \
        --port "${FCREPO_DB_PORT}" \
        --user "${FCREPO_DB_ROOT_USER}" \
        --password "${FCREPO_DB_ROOT_PASSWORD}" \
        "${@}"
}

function mysql_query {
    cat <<- EOF
-- Create fcrepo database in mariadb or mysql.
CREATE DATABASE IF NOT EXISTS ${FCREPO_DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Create fcrepo user and grant rights.
CREATE USER IF NOT EXISTS '${FCREPO_DB_USER}'@'%' IDENTIFIED BY '${FCREPO_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${FCREPO_DB_NAME}.* to '${FCREPO_DB_USER}'@'%';
FLUSH PRIVILEGES;

-- Update fcrepo password if changed.
SET PASSWORD FOR ${FCREPO_DB_USER}@'%' = PASSWORD('${FCREPO_DB_PASSWORD}')
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
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${FCREPO_DB_USER}') THEN
        CREATE ROLE ${FCREPO_DB_USER};
    END IF;
END
\$\$;

ALTER ROLE ${FCREPO_DB_USER} WITH LOGIN;
ALTER USER ${FCREPO_DB_USER} PASSWORD '${FCREPO_DB_PASSWORD}';

ALTER DATABASE ${FCREPO_DB_NAME} OWNER TO ${FCREPO_DB_USER};
GRANT ALL PRIVILEGES ON DATABASE ${FCREPO_DB_NAME} TO ${FCREPO_DB_USER};

COMMIT;
EOF
}

function postgresql_database_exists {
    execute_sql_file --database "${FCREPO_DB_NAME}" <(echo 'select 1')
}

function postgresql_create_database {
    # Postgres does not support CREATE DATABASE IF NOT EXISTS so split our logic across multiple queries.
    if ! postgresql_database_exists; then
        execute_sql_file <(echo "CREATE DATABASE ${FCREPO_DB_NAME}")
    fi
    execute_sql_file --database "${FCREPO_DB_NAME}" <(postgres_query)
}

function create_database {
    case "${FCREPO_PERSISTENCE_TYPE}" in
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

# Change log files to redirect to stdout/stderr
function redirect_logs_to_stdout { 
    ln -sf /dev/stdout /opt/tomcat/logs/velocity.log
    chown tomcat:tomcat /opt/tomcat/logs/velocity.log
}

function requires_database {
    [[ "${FCREPO_PERSISTENCE_TYPE}" = "mysql" ]] || [[ "${FCREPO_PERSISTENCE_TYPE}" = "postgresql" ]]
}

function main {
    redirect_logs_to_stdout
    if requires_database; then
        create_database
    fi
}
main
