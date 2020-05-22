#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly PROGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly ROOT="$(realpath ${PROGDIR}/..)"

readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME SERVICE
 
    Opens an ash shell in the given SERVICE's container.

    OPTIONS:
       -h --help          Show this help.
       -x --debug         Debug this script.
 
    Examples:
       $PROGNAME database
EOF
}

function cmdline {
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            # Translate --gnu-long-options to -g (short options)
            --help)       args="${args}-h ";;
            --debug)      args="${args}-x ";;
            # Pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done
 
    # Reset the positional parameters to the short options
    eval set -- $args
 
    while getopts "hx" OPTION
    do
        case $OPTION in
        h)
            usage
            exit 0
            ;;
        x)
            readonly DEBUG='-x'
            set -x
            ;;
        esac
    done

    shift $((OPTIND-1))
    readonly SERVICE="${1}"

    # Check if the service exists and is running.
    [[ -z ${SERVICE} ]] && (echo "No SERVICE specified."; usage; exit 1)
    docker-compose ps ${SERVICE} &> /dev/null || ( echo "Service ${SERVICE} does not exist."; exit 1 )
    [[ "$(docker-compose ps -q ${SERVICE})" == "" ]] && (echo "Service ${SERVICE} is not running."; exit 1)

    return 0
}

function main {
    cmdline ${ARGS}
    docker-compose -f "${ROOT}/docker-compose.yml" exec ${SERVICE} ash
}
main

