#!/command/with-contenv bash
# shellcheck shell=bash
set -e

# FCREPO_PERSISTENCE_TYPE dictates which DB_DRIVER should be used.
case "${FCREPO_PERSISTENCE_TYPE}" in
file)
    DB_DRIVER=none
    ;;
mysql)
    DB_DRIVER=mysql
    ;;
postgresql)
    DB_DRIVER=postgresql
    ;;
*)
    echo "Only file/mysql/postgresql are supported values for FCREPO_PERSISTENCE_TYPE." >&2
    exit 1
    ;;
esac

# Import derived value for DB_DRIVER into the container environment.
echo "DB_DRIVER=${DB_DRIVER}" | /usr/local/bin/confd-import-environment.sh
