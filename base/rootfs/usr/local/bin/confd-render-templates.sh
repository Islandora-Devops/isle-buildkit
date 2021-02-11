#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

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
    wait-for-confd-backend.sh
    local backend=

    case "${CONFD_BACKEND}" in
        etcd|etcdv3)
            backend=etcdv3
            ;;
        env)
            backend=env
            ;;
        *)
            # Unknown backend assume failure.
            exit 1
            ;;
    esac

    render ${backend}
}
main
