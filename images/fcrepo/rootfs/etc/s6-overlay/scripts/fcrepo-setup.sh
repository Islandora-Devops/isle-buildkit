#!/command/with-contenv bash
# shellcheck shell=bash
set -e

function mysql_create_database {
    cat <<-EOF | create-database.sh
-- Create fcrepo database in mariadb or mysql.
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Create fcrepo user and grant rights.
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* to '${DB_USER}'@'%';
FLUSH PRIVILEGES;

-- Update fcrepo password if changed.
SET PASSWORD FOR ${DB_USER}@'%' = PASSWORD('${DB_PASSWORD}')
EOF
}

function postgresql_create_database {
    cat <<-EOF | create-database.sh
BEGIN;

DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${DB_USER}') THEN
        CREATE ROLE ${DB_USER};
    END IF;
END
\$\$;

ALTER ROLE ${DB_USER} WITH LOGIN;
ALTER USER ${DB_USER} PASSWORD '${DB_PASSWORD}';

ALTER DATABASE ${DB_NAME} OWNER TO ${DB_USER};
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};

COMMIT;
EOF
}

# Some persistence backends require setup.
function setup_persistence_backend {
    case "${DB_DRIVER}" in
    none)
        # No action required.
        ;;
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

function wait_for_broker {
    local tcp="${FCREPO_ACTIVEMQ_BROKER%:*}"
    local host="${tcp##*/}"
    local port="${FCREPO_ACTIVEMQ_BROKER##*:}"

    if timeout 300 wait-for-open-port.sh "${host}" "${port}"; then
        echo "Broker Found at ${host}:${port}"
        return 0
    else
        echo "Could not connect to broker at ${host}:${port}"
        exit 1
    fi
}

function main {
    setup_persistence_backend
    # When bind mounting we need to ensure that we
    # actually can write to the folder.
    chown tomcat:tomcat /data
    # Fcrepo can fail to start if it cannot connect to an broker on startup.
    wait_for_broker
}
main
