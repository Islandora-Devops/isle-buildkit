#!/command/with-contenv bash
# shellcheck shell=bash
set -e

function mysql_create_database {
    cat <<-EOF | create-database.sh
-- Create database in mariadb or mysql.
CREATE DATABASE IF NOT EXISTS ${RIPRAP_DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Create user and grant rights.
CREATE USER IF NOT EXISTS '${RIPRAP_DB_USER}'@'%' IDENTIFIED BY '${RIPRAP_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${RIPRAP_DB_NAME}.* to '${RIPRAP_DB_USER}'@'%';
FLUSH PRIVILEGES;

-- Update user password if changed.
SET PASSWORD FOR ${RIPRAP_DB_USER}@'%' = PASSWORD('${RIPRAP_DB_PASSWORD}')
EOF
}

function postgresql_create_database {
    cat <<-EOF | create-database.sh
BEGIN;

DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${RIPRAP_DB_USER}') THEN
        CREATE ROLE ${RIPRAP_DB_USER};
    END IF;
END
\$\$;

ALTER ROLE ${RIPRAP_DB_USER} WITH LOGIN;
ALTER USER ${RIPRAP_DB_USER} PASSWORD '${RIPRAP_DB_PASSWORD}';

ALTER DATABASE ${RIPRAP_DB_NAME} OWNER TO ${RIPRAP_DB_USER};
GRANT ALL PRIVILEGES ON DATABASE ${RIPRAP_DB_NAME} TO ${RIPRAP_DB_USER};

COMMIT;
EOF
}

function create_database {
    case "${DB_DRIVER}" in
    sqlite)
        # Running migrations will create the database.
        ;;
    mysql)
        mysql_create_database
        ;;
    postgresql)
        postgresql_create_database
        ;;
    *)
        echo "Only SQLite/MySQL/PostgresSQL databases are supported for now." >&2
        exit 1
        ;;
    esac
}

function setup_cron {
    if [[ "${RIPRAP_CROND_ENABLE_SERVICE}" == "true" ]]; then
        cat <<EOF | crontab -u nginx -
# min	hour	day	month	weekday	command
${RIPRAP_CROND_SCHEDULE}	check-fixity.sh --settings=/var/www/riprap/cron_config.yml
EOF
    fi
}

function run_migrations {
    local num_migrations
    (
        cd /var/www/riprap
        s6-setuidgid nginx php bin/console --no-interaction make:migration
        num_migrations=$(find src/Migrations -type f -name "*.php" | wc -l)
        if [[ ${num_migrations} -gt 0 ]]; then
            s6-setuidgid nginx php bin/console --no-interaction doctrine:migrations:migrate
        fi
    )
}

function main {
    create_database
    run_migrations
    setup_cron
}
main
