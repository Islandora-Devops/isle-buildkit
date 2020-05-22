#!/usr/bin/env bash

set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME options
 
    Waits for an connection to an mysql database as the given user, or until the
    timeout is exceeded.

    Exits non-zero if not successful.

    OPTIONS:
       -H --host          The URL of the repository to clone.
       -P --port          The commit hash or tag to checkout.
       -u --user          The directory to checkout the repository into.
       -p --password      Remove the git repo as well as any files passed as parameters to save space.
       -t --timeout       Time to wait for a connection to the database, defaults to 60 seconds.
       -h --help          Show this help.
       -x --debug         Debug this script.
 
    Examples:
       Check if database is acccessible:
       $PROGNAME \\
                --host mariadb \\
                --port 3306 \\
                --user root \\
                --password password
EOF
}

function cmdline {
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            # Translate --gnu-long-options to -g (short options)
            --host)       args="${args}-H ";;
            --port)       args="${args}-P ";;
            --user)       args="${args}-u ";;
            --password)   args="${args}-p ";;
            --timeout)    args="${args}-t ";;
            --help)       args="${args}-h ";;
            --debug)      args="${args}-x ";;
            # Pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done
 
    # Reset the positional parameters to the short options
    eval set -- $args
 
    while getopts "H:P:u:p:thx" OPTION
    do
        case $OPTION in
        H)
            readonly DB_HOST=${OPTARG}
            ;;
        P)
            readonly DB_PORT=${OPTARG}
            ;;
        u)
            readonly DB_USER=${OPTARG}
            ;;
        p)
            readonly DB_PASSWORD=${OPTARG}
            ;;
        t)
            readonly TIMEOUT=${OPTARG}
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

    if [[ -z $DB_HOST || -z $DB_PORT || -z $DB_USER || -x $DB_PASSWORD ]]; then
        echo "Missing one or more required options: --host --port --user --password"
        exit 1
    fi

    return 0
}

function main {
    cmdline ${ARGS}
    local duration=${TIMEOUT:-300}
    echo "Waiting for up to ${duration} seconds to connect to Database ${DB_HOST}:${DB_PORT}" 
    if timeout ${duration} wait-for-open-port.sh ${DB_HOST} ${DB_PORT}; then
        echo "Database found"
    else
        exit 1
    fi
    echo "Validating Database credentials for ${DB_USER}"
    if mysqladmin -s --user=${DB_USER} --password=${DB_PASSWORD} --host=${DB_HOST} --port=${DB_PORT} --protocol=tcp ping; then
        echo "Credentials are valid"
        exit 0
    else
        echo "Credentials are invalid"
        exit 1
    fi
}
main
