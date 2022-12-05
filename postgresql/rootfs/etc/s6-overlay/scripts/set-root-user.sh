#!/command/with-contenv bash
# shellcheck shell=bash
set -e

# Use what has been provided by the user or default to the derived values.
cat <<EOF | /usr/local/bin/confd-import-environment.sh
DB_ROOT_USER={{ getenv "POSTGRESQL_ROOT_USER" "${DB_ROOT_USER}" }}
DB_ROOT_PASSWORD={{ getenv "POSTGRESQL_ROOT_PASSWORD" "${DB_ROOT_PASSWORD}" }}
EOF
