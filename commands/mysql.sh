#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly PROGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly ROOT="$(realpath ${PROGDIR}/..)"

readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME [OPTIONS] [database]
 
    Executes the mysql client inside of the database service container.

    OPTIONS:
       -h --help          Show this help.
       -x --debug         Debug this script.

    Additionally any options that are provided by the mysql client.
 
    Examples:
       $PROGNAME -u root -p drupal_default
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

    # Ignore illegal options as they get passed to mysql.
    while getopts "hx" OPTION &> /dev/null;
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

    # Check if the service exists and is running.
    [[ "$(docker-compose ps -q database)" == "" ]] && (echo "Database service is not running."; exit 1)

    return 0
}

function main {
    cmdline ${ARGS}
    docker-compose -f "${ROOT}/docker-compose.yml" exec database mysql ${ARGS}
}
main

