#!/command/with-contenv bash
# shellcheck shell=bash
set -e

ARGS=("$@")
PROGNAME=$(basename "$0")
readonly ARGS PROGNAME

function usage {
    cat <<-EOF
    usage: $PROGNAME

    Waits for confd backend specified by the CONFD_BACKEND environment variable
    to become available or until a backend dependent timeout has been exceeded.

    Exits non-zero if not successful.

    OPTIONS:
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       $PROGNAME
EOF
}

function cmdline {
    local arg=
    for arg; do
        local delim=""
        case "$arg" in
        # Translate --gnu-long-options to -g (short options)
        --help) args="${args}-h " ;;
        --debug) args="${args}-x " ;;
        # Pass through anything else
        *)
            [[ "${arg:0:1}" == "-" ]] || delim="\""
            args="${args}${delim}${arg}${delim} "
            ;;
        esac
    done

    # Reset the positional parameters to the short options
    eval set -- "${args}"

    while getopts "ahx" OPTION; do
        case $OPTION in
        h)
            usage
            exit 0
            ;;
        x)
            set -x
            ;;
        *)
            echo "Invalid Option: $OPTION" >&2
            usage
            exit 1
            ;;
        esac
    done

    return 0
}

function wait_for_connection {
    local service host port duration
    service="${1}"
    shift
    host="${service}_HOST"
    port="${service}_PORT"
    duration="${service}_CONNECTION_TIMEOUT"
    echo "Waiting for up to ${!duration} seconds to connect to ${!host}:${!port}" >&2
    # Put in subshell to supress "Teminated" message that always gets printed.
    # Its part of bashes job system and misleads those reading the log to thing
    # there was an error at startup.
    if timeout "${!duration}" wait-for-open-port.sh "${!host}" "${!port}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

function main {
    cmdline "${ARGS[@]}"

    case "${CONFD_BACKEND}" in
    etcd | etcdv3)
        if wait_for_connection ETCD; then
            exit 0
        else
            exit 1
        fi
        ;;
    env)
        # No need to wait for environment variables.
        exit 0
        ;;
    *)
        # Unknown backend assume failure.
        exit 1
        ;;
    esac
}
main
