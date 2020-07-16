#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

# Define defaults if no value environment variables are specified for the following.
readonly ETCD_HOST=${ETCD_HOST:-etcd}
readonly ETCD_PORT=${ETCD_PORT:-2379}
readonly ETCD_TIMEOUT=${ETCD_TIMEOUT:-0}
readonly CONFD_LOG_LEVEL=${CONFD_LOG_LEVEL:-error}
readonly CONFD_POLLING_INTERVAL=${CONFD_POLLING_INTERVAL:-30}

function usage {
    cat <<- EOF
    usage: $PROGNAME options

    Renders the confd templates using the backend defined by CONFD_BACKEND if found falling back to environment variables otherwise.

    By default this just renders once and exits, unless --continuous is specified.

    Exits non-zero if not successful.

    OPTIONS:
       --continuous       Render the templates continously according to the environment variable ${CONFD_POLLING_INTERVAL}.
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Render templates once then exit:
       $PROGNAME
EOF
}

function cmdline {
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            # Translate --gnu-long-options to -g (short options)
            --continuous)  args="${args}-a ";;
            --help)        args="${args}-h ";;
            --debug)       args="${args}-x ";;
            # Pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done

    # Reset the positional parameters to the short options
    eval set -- $args

    while getopts "ahx" OPTION
    do
        case $OPTION in
        a)
            readonly CONTINUOUS=1
            ;;
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

    return 0
}

function wait_for_connection {
    local service="${1}"; shift
    local host="${service}_HOST"
    local port="${service}_PORT"
    local duration="${service}_TIMEOUT"
    echo "Waiting for up to ${!duration} seconds to connect to ${!host}:${!port}"
    # Put in subshell to supress "Teminated" message that always gets printed.
    # Its part of bashes job system and misleads those reading the log to thing
    # there was an error at startup.
    if $(timeout ${!duration} wait-for-open-port.sh ${!host} ${!port} &> /dev/null); then
        return 0
    else
        return 1
    fi
}

function render {
    local backend="${1}"; shift
    local onetime_args="-onetime -sync-only"
    local continuous_args="-interval ${CONFD_POLLING_INTERVAL}"
    local args=

    if [ -z ${CONTINUOUS} ]; then
        args="${onetime_args}"
    else
        args="${continuous_args}"
    fi

    echo "confd using '${backend}' backend..."
    confd ${args} -log-level ${CONFD_LOG_LEVEL} -backend ${backend}
}

function main {
    cmdline ${ARGS}
    local backend=env # Default to env if no other backend can be reached.

    case "${CONFD_BACKEND:-etcdv3}" in
        etcd|etcdv3)
            if wait_for_connection ETCD; then
                backend=etcdv3
            fi
            ;;
        env)
            backend=env
            ;;
        *)
    esac

    render ${backend}
}
main
