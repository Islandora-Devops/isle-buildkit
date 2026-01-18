#!/command/with-contenv bash
# shellcheck shell=bash
set -ex

# Set the default value for CANTALOUPE_ENDPOINT_API_SECRET if none provided.
DEFAULT_SECRET=$(openssl rand -hex 16)
cat <<EOF | /usr/local/bin/confd-import-environment.sh
CANTALOUPE_ENDPOINT_API_SECRET="{{ getenv "CANTALOUPE_ENDPOINT_API_SECRET" "${DEFAULT_SECRET}" }}"
EOF
