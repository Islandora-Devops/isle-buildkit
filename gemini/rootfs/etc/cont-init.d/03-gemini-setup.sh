#!/usr/bin/with-contenv bash
set -e

function mysql_create_database {
    cat <<- EOF | create-database.sh
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

function postgresql_create_database {
    cat <<- EOF | create-database.sh
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

function create_database {
    case "${DB_DRIVER}" in
        mysql)
            mysql_create_database
            ;;
        postgresql)
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
