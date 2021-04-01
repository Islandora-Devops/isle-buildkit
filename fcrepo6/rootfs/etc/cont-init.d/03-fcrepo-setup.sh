#!/usr/bin/with-contenv bash
set -e

function mysql_create_database {
    cat <<- EOF | create-database.sh
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

function postgresql_create_database {
    cat <<- EOF | create-database.sh
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
    esac
}

# Change log files to redirect to stdout/stderr
function redirect_logs_to_stdout { 
    ln -sf /dev/stdout /opt/tomcat/logs/velocity.log
    chown tomcat:tomcat /opt/tomcat/logs/velocity.log
}

function main {
    redirect_logs_to_stdout
    setup_persistence_backend
    # When bind mounting we need to ensure that we
    # actually can write to the folder.
    chown tomcat:tomcat /data
}
main
