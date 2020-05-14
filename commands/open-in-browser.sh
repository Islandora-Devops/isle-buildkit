#!/usr/bin/env bash

set -e

readonly PROGNAME=$(basename $0)
readonly PROGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME SERVICE
 
    Opens the given SERVICE in the users browser.

    OPTIONS:
       -h --help          Show this help.
       -x --debug         Debug this script.
 
    Examples:
       Opens activemq web console:
       $PROGNAME activemq
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

    shift $((OPTIND-1))
    readonly SERVICE="${1}"

    # Check if the service exists and is running.
    docker-compose ps ${SERVICE} &> /dev/null || ( echo "Service ${SERVICE} does not exist."; exit 1 )
    [[ "$(docker-compose ps -q ${SERVICE})" == "" ]] && (echo "Service ${SERVICE} is not running."; exit 1)

    return 0
}

function open {
    local url="${1}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open "${url}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "open location \"${URL}\""
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        cygstart "${url}"
    else
        echo "Unknown OS ${OSTYPE}"
        exit 1
    fi
}

function image {
    local service="${1}"
    docker-compose images ${service} | tail -1 | awk '{print $1}'
}

function ip {
    local service="${1}"
    local image=$(image ${service})
    local template="{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}"
    # Assumes the default network is listed first.
    docker inspect -f "${template}" "${image}" | head -n1
}

function url {
    local service="${1}"; shift
    local port="${1}"; shift
    local path="${1}"; shift
    echo "http://$(ip ${service}):${port}${path}"
}

function main {
    cmdline ${ARGS}

    case "${SERVICE}" in
        activemq)     open "http://activemq.localhost/admin" &> /dev/null;;
        alpaca)       open $(url alpaca 8181 /system/console) &> /dev/null;;
        blazegraph)   open "http://blazegraph.localhost/bigdata" &> /dev/null;;
        cantaloupe)   open $(url cantaloupe 8080 /cantaloupe/) &> /dev/null;;
        crayfits)     open $(url crayfits 8000 /) &> /dev/null;;
        fcrepo)       open "http://fcrepo.localhost/fcrepo/rest" &> /dev/null;;
        gemini)       open $(url gemini 8000 /) &> /dev/null;;
        homarus)      open $(url homarus 8000 /) &> /dev/null;;
        houdini)      open $(url houdini 8000 /) &> /dev/null;;
        hypercube)    open $(url hypercube 8000 /) &> /dev/null;;
        drupal)       open "http://drupal.localhost" &> /dev/null;;
        milliner)     open $(url milliner 8000 /) &> /dev/null;;
        recast)       open $(url recast 8000 /) &> /dev/null;;
        solr)         open "http://solr.localhost/solr" &> /dev/null;;
        matomo)       open "http://matomo.localhost" &> /dev/null;;
        *)            exit 1;;
    esac
}
main
