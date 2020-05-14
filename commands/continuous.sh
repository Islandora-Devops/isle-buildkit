#!/usr/bin/env bash

set -e

readonly PROGNAME=$(basename $0)
readonly PROGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly ROOT="$(realpath ${PROGDIR}/..)"
readonly ARGS="$@"

# Kill background processes.
trap "kill 0" SIGINT

function usage {
    cat <<- EOF
    usage: $PROGNAME options [images, and services...]

    Continously builds and runs the given images and services.

    OPTIONS:
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
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
            --help)       args="${args}-h ";;
            --debug)      args="${args}-x ";;
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

    # All remaning parameters are files to be removed from the repo if --strip was specified.
    shift $((OPTIND-1))
    readonly INPUT=("$@")

    return 0
}

function contains {
    local search="${1}"; shift
    local list=("$@")
    local i=
    for i in "${list[@]}";
    do
        if [[ "${search}" == "${i}" ]]
        then 
            return 0
        fi
    done
    return 1
}

function services {
    docker-compose -f "${ROOT}/docker-compose.yml" config --services
}

function images {
     pushd ${PROGDIR}/.. &> /dev/null
    ./gradlew tasks --all -q | grep -e ":build[^a-zA-Z]" | sed -e 's/^\([a-zA-Z0-9_-]*\):build.*$/\1/'
    popd &> /dev/null
}

function main {
    cmdline ${ARGS}
    local images=($(images))
    local services=($(services))
    local build=()
    local run=()
    local i=
    local unknown_arg="true"

    for i in "${INPUT[@]}"
    do
        unknown_argument="true"
        if contains "${i}" "${images[@]}"; then
            build+=(${i})
            unknown_argument="false"
        fi
        if contains "${i}" "${services[@]}"; then
            run+=(${i})
            unknown_argument="false"
        fi
        if [[ "${unknown_argument}" == "true" ]]; then
            echo "Error unknown image or service: ${i}"
            exit 1
        fi
    done

    pushd ${PROGDIR}/.. &> /dev/null
    if [ -z "${INPUT}" ]; then
        ./gradlew build --continuous &
        docker-compose -f "${ROOT}/docker-compose.yml" up &
    else
        ./gradlew $(printf ":%q:build " ${build[@]}) --continuous &
        docker-compose -f "${ROOT}/docker-compose.yml" up watchtower ${run[@]} &
    fi
    popd &> /dev/null

    wait
}
main
