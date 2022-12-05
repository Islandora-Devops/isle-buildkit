#!/usr/bin/env bash
set -e

ARGS=("$@")
PROGNAME=$(basename "$0")
readonly ARGS PROGNAME

function usage() {
    cat <<-EOF
    usage: $PROGNAME options [FILE]...

    Installs the given apache service in /opt. Creates a user/group for the
    service and ensuring that all files are owned by that user/group.

    Additional parameters are files to be removed from the installation to save
    on space. Things like "examples", and "docs".

    OPTIONS:
       -n --name          The name of the services to install (used to create user/group and install directory).
       -f --file          The name of the file to download.
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Install ActiveMQ:
       $PROGNAME \\
                 --name "activemq" \\
                 --file "apache-activemq-5.14.5-bin.tar.gz" \\
                 examples webapps-demo docs
EOF
}

function cmdline() {
    local arg=
    for arg; do
        local delim=""
        case "$arg" in
        # Translate --gnu-long-options to -g (short options)
        --name) args="${args}-n " ;;
        --file) args="${args}-f " ;;
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

    while getopts "n:f:hx" OPTION; do
        case $OPTION in
        n)
            readonly NAME=${OPTARG}
            ;;
        f)
            readonly FILE="${OPTARG}"
            ;;
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

    if [[ -z $NAME || -z $FILE ]]; then
        echo "Missing one or more required options: --name --file"
        exit 1
    fi

    # All remaning parameters are files to be removed from the installation.
    shift $((OPTIND - 1))
    readonly REMOVE=("$@")

    return 0
}

function main {
    cmdline "${ARGS[@]}"
    install-service.sh --name "${NAME}" --file "${FILE}" "${REMOVE[@]}"
}
main
