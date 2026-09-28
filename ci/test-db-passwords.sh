#!/usr/bin/env bash
# Exercise real s6 startup against persistent MariaDB data. Requires built images.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
test_name="isle-db-passwords-${RANDOM}-$$"
test_tmp=$(mktemp -d)
cleanup() {
    docker rm -f "${test_name}-app" "${test_name}-db" >/dev/null 2>&1 || true
    docker network rm "${test_name}" >/dev/null 2>&1 || true
    rm -rf "${test_tmp}"
}
trap cleanup EXIT

docker network create "${test_name}" >/dev/null
docker run -d --name "${test_name}-db" --network "${test_name}" \
    --network-alias mariadb "${MARIADB:-islandora/mariadb:local}" >/dev/null
for ((attempt = 0; attempt < 60; attempt++)); do
    if docker exec "${test_name}-db" mariadb --protocol=tcp -h127.0.0.1 \
        -uroot -ppassword -e 'SELECT 1' >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

for service in drupal fcrepo; do
    image_var=${service^^}
    test_image=${!image_var:-islandora/${service}:local}
    docker exec "${test_name}-db" mariadb -uroot -e \
        "CREATE DATABASE ${service}; CREATE TABLE ${service}.preserved (id INT); INSERT INTO ${service}.preserved VALUES (42);"
    previous_password=
    for password in password first-secret second-secret; do
        docker create --name "${test_name}-app" --network "${test_name}" \
            -e DB_NAME="${service}" -e DB_USER="${service}" \
            -e DB_PASSWORD=password \
            -e MARIADB_DB_PASSWORD=ignored-legacy-value \
            -e DRUPAL_DEFAULT_DB_PASSWORD=ignored-legacy-value \
            -e FCREPO_DB_PASSWORD=ignored-legacy-value \
            -e FCREPO_PERSISTENCE_TYPE=mysql \
            -e FCREPO_ACTIVEMQ_BROKER=tcp://mariadb:3306 \
            "${test_image}" sh -c 'touch /tmp/startup-complete; sleep infinity' >/dev/null
        if [[ "${service}" == drupal ]]; then
            # Exercise the existing downstream install hook with an installed DB.
            docker cp images/test/rootfs/etc/s6-overlay/. "${test_name}-app:/etc/s6-overlay/"
        fi
        if [[ "${password}" != password ]]; then
            printf '%s' "${password}" >"${test_tmp}/DB_PASSWORD"
            docker cp "${test_tmp}/DB_PASSWORD" "${test_name}-app:/run/secrets/DB_PASSWORD"
        fi
        docker start "${test_name}-app" >/dev/null
        for ((attempt = 0; attempt < 60; attempt++)); do
            if docker exec "${test_name}-app" test -f /tmp/startup-complete 2>/dev/null; then
                break
            fi
            sleep 1
        done
        if ((attempt == 60)); then
            docker logs "${test_name}-app"
            exit 1
        fi
        if docker logs "${test_name}-app" 2>&1 | grep 'Deprecated program name'; then
            echo "Startup used a deprecated database command" >&2
            exit 1
        fi
        result=$(docker exec -e MYSQL_PWD="${password}" "${test_name}-db" \
            mariadb --protocol=tcp -h127.0.0.1 -u"${service}" -N \
            -e "SELECT id FROM ${service}.preserved")
        [[ "${result}" == 42 ]]
        if [[ -n "${previous_password}" ]] && docker exec -e MYSQL_PWD="${previous_password}" \
            "${test_name}-db" mariadb --protocol=tcp -h127.0.0.1 -u"${service}" \
            -e 'SELECT 1' >/dev/null 2>&1; then
            echo "Previous ${service} password is still valid" >&2
            exit 1
        fi
        previous_password=${password}
        docker rm -f "${test_name}-app" >/dev/null
    done
    echo "PASS: ${service} startup rotates secret passwords and preserves data"
done

if docker logs "${test_name}-db" 2>&1 | grep 'Deprecated program name'; then
    echo "MariaDB startup used a deprecated database command" >&2
    exit 1
fi
