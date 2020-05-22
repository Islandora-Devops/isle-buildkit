#!/usr/bin/env bash

set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME HOST PORT

    Waits for the given PORT to be open on HOST, re-checks every second.
 
    Use in conjunction with timeout.

    OPTIONS:
       -h --help          Show this help.
       -x --debug         Debug this script.
 
    Examples:
      Check if database is acccessible:
      timeout 10 $PROGNAME database 3306
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
    
    if [ "$#" -ne 2 ]; then
      echo "Illegal number of parameters"
      usage
      return 1
    fi

    readonly HOST=${1}; shift
    readonly PORT=${1}

    return 0
}

function main {
  cmdline ${ARGS}
  echo "Waiting for ${PORT} on ${HOST} to open."
  while ! nc -z -w5 $HOST $PORT &> /dev/null; do
    sleep 1
  done
  exit 0;
}
main
