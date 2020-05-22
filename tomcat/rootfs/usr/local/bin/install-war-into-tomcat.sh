#!/usr/bin/env bash

# Exit non-zero if any command fails.
set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

readonly DOWNLOAD_CACHE_DIRECTORY=/opt/downloads

function usage {
    cat <<- EOF
    usage: $PROGNAME options [FILE]...
 
    Installs the given war into tomcat. Makes use of the Buildkit cache,
    by first downlading to ${DOWNLOAD_CACHE_DIRECTORY}.

    OPTIONS:
       -n --name          The name to use for the unpacked war.
       -u --url           The location to download the war from.
       -u --file          The location to copy the war from.
       -k --key           A sha256 key used to verify the intended war was downloaded successfully.
       -h --help          Show this help.
       -x --debug         Debug this script.

    The options --file and --url are mutually exclusive.

    Examples:
       Install Blazegraph as bigdata:
       $PROGNAME \\
                 --name "bigdata" \\
                 --url "https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_RELEASE_CANDIDATE_2_1_5/blazegraph.war" \\
                 --key "b22f1a1aa8e536443db9a57da63720813374ef59e4021cfa9ad0e98f9a420e85"
EOF
}

function cmdline {
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            # Translate --gnu-long-options to -g (short options)
            --name)       args="${args}-n ";;
            --url)        args="${args}-u ";;
            --file)       args="${args}-f ";;
            --key)        args="${args}-k ";;
            --help)       args="${args}-h ";;
            --debug)      args="${args}-x ";;
            # Pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done
 
    # Reset the positional parameters to the short options
    eval set -- $args
 
    while getopts "n:u:f:k:hx" OPTION
    do
        case $OPTION in
        n)
            readonly NAME=${OPTARG}
            readonly DEPLOY_DIRECTORY="/opt/tomcat/webapps/${NAME}"
            ;;
        u)
            readonly URL=${OPTARG}
            ;;
        f)
            readonly FILE=${OPTARG}
            ;;
        k)
            readonly KEY=${OPTARG}
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

    if [[ -z $NAME || -z $KEY ]]; then
        echo "Missing one or more required options: --name --key"
        exit 1
    fi

    if [[ -z $URL && -z $FILE ]]; then
        echo "Missing required options you must specify either: --url OR --file"
        exit 1
    fi

    return 0
}

function validate {
    local war="${1}"
    sha256sum "${war}" | cut -f1 -d' ' | xargs test "${KEY}" == 
}

function unpack {
    local war="${1}"
    s6-setuidgid tomcat mkdir "${DEPLOY_DIRECTORY}"
    s6-setuidgid tomcat unzip "${war}" -d "${DEPLOY_DIRECTORY}"
}

function main {
    cmdline ${ARGS}
    local war=${FILE}
    if [[ $URL ]]; then
        war="/opt/downloads/$(basename ${URL})"
        # Expects that the RUN uses ${DOWNLOAD_CACHE_DIRECTORY} as a cache
        # https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/experimental.md#run---mounttypecache
        wget -N -P ${DOWNLOAD_CACHE_DIRECTORY} ${URL}
    fi
    validate "${war}"
    unpack "${war}"
}
main
