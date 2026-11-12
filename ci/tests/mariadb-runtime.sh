#!/usr/bin/env bash
# Check the ISLE startup contract on the upstream MariaDB runtime.
# Set MARIADB_PREVIOUS to initialize the volume with a previous image first.
set -euo pipefail
image=${MARIADB:-islandora/mariadb:local}
name="isle-mariadb-runtime-$$"
volume="${name}-data"
tmp=$(mktemp -d)
cleanup() {
    status=$?
    if [[ "$status" != 0 ]]; then docker logs "$name" >&2 || true; fi
    docker rm -fv "$name" >/dev/null 2>&1 || true
    docker volume rm "$volume" >/dev/null 2>&1 || true
    rm -rf "$tmp"
}
trap cleanup EXIT

# A secret must override the environment value, including after recreation.
printf '%s' 'runtime-test-secret' > "$tmp/DB_ROOT_PASSWORD"
docker volume create "$volume" >/dev/null
start() {
    docker create --name "$name" \
        --mount "type=volume,source=$volume,target=/var/lib/mysql" \
        --env DB_ROOT_PASSWORD=wrong-environment-password \
        --env MYSQL_MAX_ALLOWED_PACKET=33554432 \
        --env MYSQL_TRANSACTION_ISOLATION=SERIALIZABLE \
        --health-interval=1s \
        "${1:-$image}" >/dev/null
    docker cp "$tmp/DB_ROOT_PASSWORD" "$name:/run/secrets/DB_ROOT_PASSWORD"
    docker start "$name" >/dev/null
    for ((attempt = 0; attempt < 120; attempt++)); do
        if sql 'SELECT 1' >/dev/null 2>&1; then return; fi
        if [[ $(docker inspect -f '{{.State.Running}}' "$name") != true ]]; then
            echo 'MariaDB exited before accepting connections' >&2
            return 1
        fi
        sleep 1
    done
    echo 'Timed out waiting for MariaDB' >&2
    return 1
}
sql() {
    docker exec --env MYSQL_PWD=runtime-test-secret "$name" \
        mysql --protocol=tcp --host=127.0.0.1 --user=root --batch --skip-column-names -e "$1"
}

start "${MARIADB_PREVIOUS:-$image}"
[[ $(sql 'SELECT @@global.max_allowed_packet') == 33554432 ]]
[[ $(sql 'SELECT @@global.tx_isolation') == SERIALIZABLE ]]
if docker exec --env MYSQL_PWD=wrong-environment-password "$name" \
    mysql --protocol=tcp --host=127.0.0.1 --user=root -e 'SELECT 1' >/dev/null 2>&1; then
    echo 'Environment password unexpectedly overrode the secret' >&2
    exit 1
fi
sql 'CREATE DATABASE runtime_test; CREATE TABLE runtime_test.data (id INT PRIMARY KEY); INSERT INTO runtime_test.data VALUES (42)'
docker stop --time 30 "$name" >/dev/null
[[ $(docker inspect -f '{{.State.ExitCode}}' "$name") == 0 ]]
docker rm "$name" >/dev/null

# Exercise migration from Alpine ownership even when no previous image is given.
docker run --rm --entrypoint chown \
    --mount "type=volume,source=$volume,target=/var/lib/mysql" \
    "$image" -R 100:101 /var/lib/mysql

start
[[ $(sql 'SELECT id FROM runtime_test.data') == 42 ]]
docker exec "$name" bash -c "$(docker inspect -f '{{index .Config.Healthcheck.Test 1}}' "$name")"
echo 'MariaDB secrets, configuration, TCP authentication, shutdown, and persistence checks passed'
