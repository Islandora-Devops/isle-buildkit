#!/usr/bin/with-contenv bash
set -e

# HANDLE_PERSISTENCE_TYPE dictates which DB_DRIVER should be used.
case "${HANDLE_PERSISTENCE_TYPE}" in
    bdbje)
        DB_DRIVER=none
        ;;
    mysql)
        DB_DRIVER=mysql
        ;;
    postgresql)
        DB_DRIVER=postgresql
        ;;
    *)
        echo "Only bdbje/mysql/postgresql are supported values for HANDLE_PERSISTENCE_TYPE." >&2
        exit 1
esac

# Import derived value for DB_DRIVER into the container environment.
echo "DB_DRIVER=${DB_DRIVER}" | /usr/local/bin/confd-import-environment.sh
