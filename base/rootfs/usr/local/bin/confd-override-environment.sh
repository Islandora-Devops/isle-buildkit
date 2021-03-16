#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

function usage() {
    cat <<- EOF
    usage: $PROGNAME

    With a given prefix find all environment variables that have that prefix
    'A', match that list against environment varaibles that use them as suffixes
    'B', and override the value of 'A' with 'B'.

    This allows values like FITS_TOMCAT_CATALINA_OPTS to replace
    TOMCAT_CATALINA_OPTS. If no value is provided that overrides the original,
    the original stays the same.

    OPTIONS:
       -p --prefix        Prefix to find the environment variables to override (Required).
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       $PROGNAME --prefix TOMCAT
EOF
}

function cmdline() {
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            # Translate --gnu-long-options to -g (short options)
            --prefix)     args="${args}-p ";;
            --help)       args="${args}-h ";;
            --debug)      args="${args}-x ";;
            # Pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done

    # Reset the positional parameters to the short options
    eval set -- $args

    while getopts "p:hx" OPTION
    do
        case $OPTION in
        p)
            readonly PREFIX=${OPTARG}
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

    if [[ -z $PREFIX ]]; then
        echo "Missing one of required options: --prefix" >&2
        exit 1
    fi

    return 0
}

function main {
    cmdline ${ARGS}
    ENVIRONMENT_VARIABLES=$(with-contenv env | egrep "^${PREFIX}_" | cut -f1 -d=)

    # Overwrite environment variables only if suitable canidate exists.
    {
        for ENVIRONMENT_VARIABLE in ${ENVIRONMENT_VARIABLES}
        do
            FILE=(/var/run/s6/container_environment/*_${ENVIRONMENT_VARIABLE})
            if [ -f "${FILE}" ]; then
                DEFAULT_VAR=$(basename "${FILE}")
                echo "${ENVIRONMENT_VARIABLE}=\"{{ getenv \"${DEFAULT_VAR}\" }}\""
            fi
        done
    } | /usr/local/bin/confd-import-environment.sh
}
main
