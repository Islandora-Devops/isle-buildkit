#!/usr/bin/env bash
readonly PROGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly ROOT="$(realpath ${PROGDIR}/..)"
docker-compose -f "${ROOT}/docker-compose.yml" exec database mysql ${@}
