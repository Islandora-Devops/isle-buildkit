#!/usr/bin/env bash
readonly PROGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly ROOT="$(realpath ${PROGDIR}/..)"
docker-compose -f "${ROOT}/docker-compose.yml" exec drupal s6-setuidgid nginx php -d memory_limit=-1 /usr/local/bin/drush ${@}
