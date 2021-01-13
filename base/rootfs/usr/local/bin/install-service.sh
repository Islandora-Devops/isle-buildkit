#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

function usage() {
    cat <<- EOF
    usage: $PROGNAME options [FILE]...

    Creates a user/group for the service and as well as a directory in /opt
    ensuring that all files are owned by that user/group.

    Unpacks the specified archive into the install directory as well.

    Additional parameters are files to be removed from the installation to save
    on space. Things like "examples", and "docs", etc.

    OPTIONS:
       -n --name          The name of the services to install (used to create user/group and install directory).
       -f --file          The name of the archive to unpack into the install directory.
       -d --depth         Some archives have extraneous parent folders they are nested in the depth indicates how many should be ignored, defaults to 1.
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
    for arg
    do
        local delim=""
        case "$arg" in
            # Translate --gnu-long-options to -g (short options)
            --name)       args="${args}-n ";;
            --file)       args="${args}-f ";;
            --depth)      args="${args}-d ";;
            --help)       args="${args}-h ";;
            --debug)      args="${args}-x ";;
            # Pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done

    # Reset the positional parameters to the short options
    eval set -- $args

    while getopts "n:f:d:hx" OPTION
    do
        case $OPTION in
        n)
            readonly NAME=${OPTARG}
            ;;
        f)
            readonly FILE="${OPTARG}"
            ;;
        d)
            readonly DEPTH="${OPTARG}"
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

    if [[ -z $NAME || -z $FILE ]]; then
        echo "Missing one or more required options: --name --file"
        exit 1
    fi

    # Use default depth if not specified.
    if [[ -z $DEPTH ]]; then
        readonly DEPTH=1
    fi

    # All remaning parameters are files to be removed from the installation.
    shift $((OPTIND-1))
    readonly REMOVE=("$@")

    return 0
}

function main {
    cmdline ${ARGS}
    local install_directory=/opt/${NAME}
    create-service-user.sh --name ${NAME}
    case $FILE in 
    *.tar.gz|*.tgz)
        s6-setuidgid ${NAME} tar -xzf ${FILE} -C ${install_directory} --strip-components ${DEPTH}
        ;;
    *)
        echo "Unable to unpack ${FILE} please update script to support additional formats."
        exit 1
        ;;
    esac
    # Remove extraneous files.
    for i in "${REMOVE[@]}"; do
        rm -fr "${install_directory}/${i}"
    done
}
main
