#!/usr/bin/with-contenv bash
set -e

function execute_sql_file {
    execute-sql-file.sh \
        --driver "${HANDLE_PERSISTENCE_TYPE}" \
        --host "${HANDLE_DB_HOST}" \
        --port "${HANDLE_DB_PORT}" \
        --user "root" \
        --password "${HANDLE_DB_ROOT_PASSWORD}" \
        "${@}"
}

function mysql_query {
    cat <<- EOF
-- Create handle database in mariadb or mysql.
CREATE DATABASE IF NOT EXISTS ${HANDLE_DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
-- Create handle user and grant rights.
CREATE USER IF NOT EXISTS '${HANDLE_DB_USER}'@'%' IDENTIFIED BY '${HANDLE_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${HANDLE_DB_NAME}.* to '${HANDLE_DB_USER}'@'%';
FLUSH PRIVILEGES;
-- Update handle password if changed.
SET PASSWORD FOR ${HANDLE_DB_USER}@'%' = PASSWORD('${HANDLE_DB_PASSWORD}');
USE ${HANDLE_DB_NAME};
CREATE TABLE IF NOT EXISTS nas (
na varchar(255) not null,
PRIMARY KEY(na)
);

CREATE TABLE IF NOT EXISTS handles (
handle varchar(255) not null,
idx int4 not null,
type blob,
data blob,
ttl_type int2,
ttl int4,
timestamp int4,
refs blob,
admin_read bool,
admin_write bool,
pub_read bool,
pub_write bool,
PRIMARY KEY(handle, idx)
);

EOF
}

function mysql_create_database {
    echo "creating db"
    execute_sql_file <(mysql_query)
}

function postgres_query {
    cat <<- EOF
BEGIN;
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${HANDLE_DB_USER}') THEN
        CREATE ROLE ${HANDLE_DB_USER};
    END IF;
END
\$\$;
ALTER ROLE ${HANDLE_DB_USER} WITH LOGIN;
ALTER USER ${HANDLE_DB_USER} PASSWORD '${HANDLE_DB_PASSWORD}';
ALTER DATABASE ${HANDLE_DB_NAME} OWNER TO ${HANDLE_DB_USER};
GRANT ALL PRIVILEGES ON DATABASE ${HANDLE_DB_NAME} TO ${HANDLE_DB_USER};
COMMIT;
CREATE TABLE IF NOT EXISTS nas (
na varchar(255) not null,
PRIMARY KEY(na)
);

CREATE TABLE IF NOT EXISTS handles (
handle varchar(255) not null,
idx int4 not null,
type blob,
data blob,
ttl_type int2,
ttl int4,
timestamp int4,
refs blob,
admin_read bool,
admin_write bool,
pub_read bool,
pub_write bool,
PRIMARY KEY(handle, idx)
);
COMMIT;
EOF
}

function postgresql_database_exists {
    execute_sql_file --database "${HANDLE_DB_NAME}" <(echo 'select 1')
}

function postgresql_create_database {
    # Postgres does not support CREATE DATABASE IF NOT EXISTS so split our logic across multiple queries.
    if ! postgresql_database_exists; then
        execute_sql_file <(echo "CREATE DATABASE ${HANDLE_DB_NAME}")
    fi
    execute_sql_file --database "${HANDLE_DB_NAME}" <(postgres_query)
}

function create_database {
    case "${HANDLE_PERSISTENCE_TYPE}" in
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
    ln -sf /dev/stdout /var/handle/logs/access.log
    ln -sf /dev/stderr /var/handle/logs/error.log
}

function requires_database {
    [[ "${HANDLE_PERSISTENCE_TYPE}" = "mysql" ]] || [[ "${HANDLE_PERSISTENCE_TYPE}" = "postgresql" ]]
}

function main {
    redirect_logs_to_stdout
    if requires_database; then
        create_database
    fi
}
main
