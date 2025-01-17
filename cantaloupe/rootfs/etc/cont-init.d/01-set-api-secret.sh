#!/usr/bin/with-contenv bash
set -e

ENV_FILE="/var/run/s6/container_environment/CANTALOUPE_ENDPOINT_API_SECRET"
if [ ! -s "$ENV_FILE" ]; then
    openssl rand -hex 16 > "$ENV_FILE"
    echo "CANTALOUPE_ENDPOINT_API_SECRET was empty. Set to a new random value."
fi
