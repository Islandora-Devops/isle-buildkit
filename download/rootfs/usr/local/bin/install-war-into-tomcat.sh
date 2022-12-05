#!/usr/bin/env bash
set -e

ARGS=("$@")
PROGNAME=$(basename "$0")
readonly ARGS PROGNAME

function usage {
    cat <<-EOF
    usage: $PROGNAME options [FILE]...

    Installs the given war into tomcat.

    OPTIONS:
       -n --name          The name to use for the unpacked war.
       -f --file          The location to copy the war from.
       -h --help          Show this help.
       -x --debug         Debug this script.

    The options --file and --url are mutually exclusive.

    Examples:
       Install Blazegraph as bigdata:
       $PROGNAME --name "bigdata" --file /opt/downloads/blazegraph.war"
EOF
}

function cmdline {
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
            readonly DEPLOY_DIRECTORY="/opt/tomcat/webapps/${NAME}"
            ;;
        f)
            readonly FILE=${OPTARG}
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
        echo "Missing one of required options: --name --file"
        exit 1
    fi

    return 0
}

function main {
    cmdline "${ARGS[@]}"
    mkdir -p "${DEPLOY_DIRECTORY}"
    unzip "${FILE}" -d "${DEPLOY_DIRECTORY}"
    chown -R 100:1000 /opt/tomcat
}
main
