#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly PROGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly ROOT="$(realpath ${PROGDIR}/..)"

readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME [OPTIONS]
 
    Executes the drush command inside of the drupal service container.

    OPTIONS:
       -h --help          Show this help.
       -x --debug         Debug this script.

    Additionally any options that are provided by the drush command.
 
    Examples:
       Clear the Drupal cache:
       $PROGNAME cr
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
    [[ "$(docker-compose ps -q drupal)" == "" ]] && (echo "Drupal service is not running."; exit 1)

    return 0
}

function main {
    cmdline ${ARGS}
    docker-compose -f "${ROOT}/docker-compose.yml" exec drupal s6-setuidgid nginx php -d memory_limit=-1 /usr/local/bin/drush ${ARGS}
}
main
