#!/usr/bin/env bash
set -e

ARGS=("$@")
PROGNAME=$(basename "$0")
readonly ARGS PROGNAME

function usage {
    cat <<-EOF
    usage: $PROGNAME

    Runs all the scripts in /etc/cleanup.d

    OPTIONS:
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Clone repository:
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

    while getopts "hx" OPTION; do
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

function main {
    cmdline "${ARGS[@]}"
    for file in /etc/cleanup.d/*; do
        $file
    done
}
main
