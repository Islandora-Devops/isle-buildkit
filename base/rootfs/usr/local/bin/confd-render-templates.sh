#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME options

    Renders the confd templates according to specified environment variables:
    
    - CONFD_BACKEND
    - CONFD_LOG_LEVEL
    - ETCD_CONNECTION_TIMEOUT
    - ETCD_HOST
    - ETCD_PORT
    - etc

    Addional options are passed on to confd.

    Exits non-zero if not successful.

    OPTIONS:
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
            --help)        args="${args}-h ";;
            --debug)       args="${args}-x ";;
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

    # Remaining options to be passed onto the client, preceeded by '--'.
    if [ "$#" -gt 0 ]; then
        readonly OPTIONS=(${@}); shift $#
    else
        readonly OPTIONS=()
    fi

    return 0
}

function main {
    cmdline ${ARGS}
    local args="-log-level ${CONFD_LOG_LEVEL}"

    # If using remote backend make sure it is accessible before continuing
    wait-for-confd-backend.sh

    case "${CONFD_BACKEND}" in
        etcd|etcdv3)
            args="${args} -backend etcdv3 -node http://${ETCD_HOST}:${ETCD_PORT}"
            ;;
        env)
            args="${args} -backend env"
            ;;
        *)
            # Unknown backend assume failure.
            exit 1
            ;;
    esac

    exec confd ${args} "${OPTIONS[@]}"
}
main
