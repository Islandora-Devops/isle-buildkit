#!/command/with-contenv bash
# shellcheck shell=bash
set -e

function mysql_create_database {
    echo "Initializing MySQL database"
    cat <<-EOF | create-database.sh
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
na varchar(255) NOT NULL,
PRIMARY KEY(na)
);

CREATE TABLE IF NOT EXISTS handles (
handle varchar(255) NOT NULL,
idx int4 NOT NULL,
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

function postgresql_create_database {
    echo "Initializing PostGreSQL database"
    cat <<-EOF | create-database.sh
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
na varchar(255) NOT NULL,
PRIMARY KEY(na)
);
ALTER TABLE nas OWNER TO ${HANDLE_DB_USER};

CREATE TABLE IF NOT EXISTS handles (
handle varchar(255) NOT NULL,
idx int4 NOT NULL,
type bytea,
data bytea,
ttl_type int2,
ttl int4,
timestamp int4,
refs bytea,
admin_read bytea,
admin_write bool,
pub_read bool,
pub_write bool,
PRIMARY KEY(handle, idx)
);
ALTER TABLE handles OWNER TO ${HANDLE_DB_USER};
EOF
}

function create_database {
    case "${DB_DRIVER}" in
    none) ;;

    mysql)
        mysql_create_database
        ;;
    postgresql)
        postgresql_create_database
        ;;
    *)
        echo "Only mysql/postgresql are supported values for DB_DRIVER." >&2
        exit 1
        ;;
    esac
}

# Change log files to redirect to stdout/stderr
function redirect_logs_to_stdout {
    ln -sf /dev/stdout /var/handle/logs/access.log
    ln -sf /dev/stderr /var/handle/logs/error.log
    chown -h handle:handle /var/handle/logs/*
    chmod o+w /dev/stdout /dev/stderr
}

function main {
    redirect_logs_to_stdout
    create_database
}
main
