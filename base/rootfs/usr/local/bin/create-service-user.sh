#!/usr/bin/env bash
set -e

ARGS=("$@")
PROGNAME=$(basename "$0")
readonly ARGS PROGNAME

function usage() {
    cat <<-EOF
    usage: $PROGNAME options [DIR]...

    Creates a user/group for the service and as well as a directory in /opt
    ensuring that all files are owned by that user/group.

    Additional parameters are directories to be created, and owned by the new
    user/group.

    OPTIONS:
       -n --name          The name of the user (used to create user/group and home directory).
       -g --group         The secondary group to add the user to (Optional).
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Create user/group "activemq" and home folder /opt/activemq:
       $PROGNAME --name "activemq"
EOF
}

function cmdline() {
    local arg=
    for arg; do
        local delim=""
        case "$arg" in
        # Translate --gnu-long-options to -g (short options)
        --name) args="${args}-n " ;;
        --group) args="${args}-g " ;;
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

    while getopts "n:g:hx" OPTION; do
        case $OPTION in
        n)
            readonly NAME=${OPTARG}
            ;;
        g)
            readonly GROUP=${OPTARG}
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

    if [[ ! -v NAME ]]; then
        echo "Missing one or more required options: --name" >&2
        exit 1
    fi

    # All remaning parameters are directories to be created.
    shift $((OPTIND - 1))
    DIRECTORIES=("$@")
    readonly DIRECTORIES

    return 0
}

function main {
    local install_directory user group
    cmdline "${ARGS[@]}"

    install_directory="/opt/${NAME}"
    user="${NAME}"
    group="${NAME}"
    mkdir -p "${install_directory}"
    addgroup "${group}" # Primary group is always the same as the name.
    # Users that run services should permit login and should not require passwords.
    adduser --system --disabled-password --no-create-home --ingroup "${group}" --shell /sbin/nologin --home "${install_directory}" "${user}"
    # User also needs to be a member of tty to write directly to /dev/stdout, etc.
    addgroup "${user}" tty
    # Optional secondary group.
    if [[ -v GROUP ]]; then
        addgroup "${NAME}" "${GROUP}"
    fi
    if ((${#DIRECTORIES[@]})); then
        mkdir -p "${DIRECTORIES[@]}"
    fi
    chown -R "${user}:${group}" "${install_directory}" "${DIRECTORIES[@]}"
}
main
