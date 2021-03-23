#!/usr/bin/env bash
set -e

# This is stage `00-container-environment-02` so child images can provide
# custom logic for setting the DB_DRIVER as stage `00-container-environment-01`.

# Dervive DB_HOST/DB_PORT from the given driver if not specified.
DB_DRIVER=$(</var/run/s6/container_environment/DB_DRIVER)
case "${DB_DRIVER}" in
    none)
        ;;
    mysql)
        DB_HOST=$(</var/run/s6/container_environment/DB_MYSQL_HOST)
        DB_PORT=$(</var/run/s6/container_environment/DB_MYSQL_PORT)
        ;;
    postgresql)
        DB_HOST=$(</var/run/s6/container_environment/DB_POSTGRESQL_HOST)
        DB_PORT=$(</var/run/s6/container_environment/DB_POSTGRESQL_PORT)
        ;;
    *)
        echo "Only mysql or postgresql are supported values for DB_DRIVER." >&2
        exit 1
esac

# Use what has been provided by the user or default to the derived values.
cat << EOF | /usr/local/bin/confd-import-environment.sh
DB_HOST={{ getenv "DB_HOST" "${DB_HOST}" }}
DB_PORT={{ getenv "DB_PORT" "${DB_PORT}" }}
EOF

# Allow DB_NAME to be overridden by FCREPO_DB_NAME, etc.
/usr/local/bin/confd-override-environment.sh --prefix DB
