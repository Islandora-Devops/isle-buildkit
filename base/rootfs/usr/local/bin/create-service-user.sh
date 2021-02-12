#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

function usage() {
    cat <<- EOF
    usage: $PROGNAME options

    Creates a user/group for the service and as well as a directory in /opt
    ensuring that all files are owned by that user/group.

    OPTIONS:
       -n --name          The name of the user (used to create user/group and home directory).
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Create user/group "activemq" and home folder /opt/activemq:
       $PROGNAME --name "activemq" 
EOF
}

function cmdline() {
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            # Translate --gnu-long-options to -g (short options)
            --name)       args="${args}-n ";;
            --help)       args="${args}-h ";;
            --debug)      args="${args}-x ";;
            # Pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done

    # Reset the positional parameters to the short options
    eval set -- $args

    while getopts "n:hx" OPTION
    do
        case $OPTION in
        n)
            readonly NAME=${OPTARG}
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

    if [[ -z $NAME ]]; then
        echo "Missing one or more required options: --name"
        exit 1
    fi

    return 0
}

function main {
    cmdline ${ARGS}
    local install_directory=/opt/${NAME}
    local user=${NAME}
    local group=${NAME}
    mkdir ${install_directory}
    addgroup ${group}
    # Users that run services should permit login / do not require passwords.
    adduser --system --disabled-password --no-create-home --ingroup ${group} --shell /sbin/nologin --home ${install_directory} ${user}
    chown ${user}:${group} ${install_directory}
}
main
