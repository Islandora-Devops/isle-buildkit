#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly PROGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly ROOT="$(realpath ${PROGDIR}/..)"

readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME [OPTIONS] [PARAMS]
 
    Executes etcdctl command inside of the etcd service container.

    OPTIONS:
       -h --help          Show this help.
       -x --debug         Debug this script.

    Additionally any options that are provided by etcdctl.
 
    Examples:
       Display etcdctl help:
       $PROGNAME help 

       Put a key/value into the store:
       $PROGNAME put /houdini/log/level DEBUG

       Get a value for the given key:
       $PROGNAME get /houdini/log/level

       Get help for sub-command:
       $PROGNAME put -h
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

    # Ignore illegal options as they get passed to etcdctl.
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
    [[ "$(docker-compose ps -q etcd)" == "" ]] && (echo "Etcd service is not running."; exit 1)

    return 0
}

function main {
    cmdline ${ARGS}
    docker-compose -f "${ROOT}/docker-compose.yml" exec etcd etcdctl ${ARGS}
}
main
