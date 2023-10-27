#!/command/with-contenv bash
# shellcheck shell=bash
set -e

# Use what has been provided by the user or default value of 256M
cat <<EOF | /usr/local/bin/confd-import-environment.sh
    DB_MAX_ALLOWED_PACKET={{ getenv "DB_MAX_ALLOWED_PACKET" "${DB_MAX_ALLOWED_PACKET}" }}
EOF
