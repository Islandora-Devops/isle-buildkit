#!/usr/bin/env bash
set -e

ARGS=("$@")
PROGNAME=$(basename "$0")
readonly ARGS PROGNAME

function usage {
    cat <<-EOF
    usage: $PROGNAME options

    Waits for an connection to an database as the given user, or until the
    timeout is exceeded.

    Exits non-zero if not successful.

    OPTIONS:
       --driver           The database driver.
       --host             The database host.
       --port             The database port.
       --user             The user to connect as.
       --password         The password to use for the user.
       --timeout          Time to wait for a connection to the database, defaults to 5 minutes. (Optional)
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Check if database is acccessible:
       $PROGNAME \\
                --driver mysql \\
                --host database \\
                --port 3306 \\
                --user root \\
                --password password
EOF
}

function cmdline {
    local arg=
    for arg; do
        local delim=""
        case "$arg" in
        # Translate --gnu-long-options to -g (short options)
        --driver) args="${args}-a " ;;
        --host) args="${args}-b " ;;
        --port) args="${args}-c " ;;
        --user) args="${args}-d " ;;
        --password) args="${args}-e " ;;
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

    while getopts "a:b:c:d:e:hx" OPTION; do
        case $OPTION in
        a)
            readonly DRIVER=${OPTARG}
            ;;
        b)
            readonly HOST=${OPTARG}
            ;;
        c)
            readonly PORT=${OPTARG}
            ;;
        d)
            readonly USER=${OPTARG}
            ;;
        e)
            readonly PASSWORD=${OPTARG}
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

    if [[ -z $DRIVER || -z $HOST || -z $PORT || -z $USER || -z $PASSWORD ]]; then
        echo "Missing one of required options: --driver --host --port --user --password" >&2
        exit 1
    fi

    return 0
}

function wait_for_connection {
    local duration=${TIMEOUT:-300}
    echo "Waiting for up to ${duration} seconds to connect to Database ${HOST}:${PORT}" >&2
    timeout "${duration}" wait-for-open-port.sh "${HOST}" "${PORT}"
}

function mysql_validate_credentials {
    mysqladmin \
        -s \
        --user="${USER}" \
        --password="${PASSWORD}" \
        --host="${HOST}" \
        --port="${PORT}" \
        --protocol=tcp \
        ping
}

function postgresql_validate_credentials {
    PGPASSWORD="${PASSWORD}" psql \
        --host="${HOST}" \
        --port="${PORT}" \
        --username="${USER}" \
        --dbname="postgres" \
        -c "\q"
}

function validate_credentials {
    echo "Validating Database credentials" >&2
    case "${DRIVER}" in
    mysql)
        mysql_validate_credentials
        ;;
    postgresql)
        postgresql_validate_credentials
        ;;
    *)
        echo "Only MySQL/PostgresSQL databases are supported for now." >&2
        exit 1
        ;;
    esac
}

function main {
    cmdline "${ARGS[@]}"

    if wait_for_connection; then
        echo "Database found" >&2
    else
        echo "Timed out waiting for database connection" >&2
        exit 1
    fi

    if validate_credentials; then
        echo "Credentials are valid" >&2
        exit 0
    else
        echo "Credentials are invalid" >&2
        exit 1
    fi
}
main
