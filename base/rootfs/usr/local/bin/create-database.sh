#!/usr/bin/env bash
set -e

ARGS=("$@")
PROGNAME=$(basename "$0")
readonly ARGS PROGNAME

function usage() {
    cat <<-EOF
    usage: $PROGNAME options FILE

    With no FILE, or when FILE is -, read standard input.

    Wrapper around execute-sql-file.sh that handles some of the oddities of
    postgresql, etc.

    If any of the options are not provided they will be derived from their
    respective 'DB' environment variables.

    Warning: by default DB_ROOT_USER/DB_ROOT_PASSWORD will be used if the
    respective options are not specified.

    OPTIONS:
       --driver           The database driver.
       --host             The database host.
       --port             The database port.
       --user             The user to connect as.
       --password         The password to use for the user.
       --database         The database to create.
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Create a new database assuming DB_DRIVER is mysql:
       echo 'CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;' | $PROGNAME
EOF
}

# Check if a fallback is required / missing.
function fallback {
    local option=${1}
    local name=${2}
    local fallback=${3}
    if [[ -z ${!name} ]]; then
        if [[ -z ${!fallback} ]]; then
            echo "Missing option ${option} and fallback environment variable ${fallback}" >&2
            exit 1
        else
            return 0
        fi
    fi
    return 1
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
        --database) args="${args}-f " ;;
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

    while getopts "a:b:c:d:e:f:hx" OPTION; do
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
        f)
            readonly NAME=${OPTARG}
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

    if fallback "--database" "NAME" "DB_NAME"; then
        readonly NAME=${DB_NAME}
    fi

    if fallback "--user" "USER" "DB_ROOT_USER"; then
        readonly USER=${DB_ROOT_USER}
    fi

    if fallback "--password" "PASSWORD" "DB_ROOT_PASSWORD"; then
        readonly PASSWORD=${DB_ROOT_PASSWORD}
    fi

    if fallback "--driver" "DRIVER" "DB_DRIVER"; then
        readonly DRIVER=${DB_DRIVER}
    fi

    if fallback "--host" "HOST" "DB_HOST"; then
        readonly HOST=${DB_HOST}
    fi

    if fallback "--port" "PORT" "DB_PORT"; then
        readonly PORT=${DB_PORT}
    fi

    shift $((OPTIND - 1))

    # Allow either passing in a file/pipe or reading from stdin by specifiying "-" or
    # ommiting completely.
    if [[ -f "${1}" || -p "${1}" ]]; then
        readonly FILE="${1}"
        shift
    elif [[ "${1}" == "-" ]]; then
        readonly FILE=/dev/stdin
        shift
    else
        readonly FILE=/dev/stdin
    fi

    return 0
}

function execute_sql_file {
    execute-sql-file.sh \
        --driver "${DRIVER}" \
        --host "${HOST}" \
        --port "${PORT}" \
        --user "${USER}" \
        --password "${PASSWORD}" \
        "${@}"
}

function postgresql_database_exists {
    execute_sql_file --database "${NAME}" <(echo 'select 1')
}

function postgresql_create_database {
    # Postgres does not support CREATE DATABASE IF NOT EXISTS so split our logic across multiple queries.
    if ! postgresql_database_exists; then
        execute_sql_file <(echo "CREATE DATABASE ${NAME}")
    fi
    execute_sql_file --database "${NAME}" "${FILE}"
}

function mysql_create_database {
    execute_sql_file "${FILE}"
}

function main {
    cmdline "${ARGS[@]}"
    case "${DRIVER}" in
    mysql)
        mysql_create_database
        ;;
    postgresql)
        postgresql_create_database
        ;;
    *)
        echo "Only MySQL/PostgresSQL databases are supported for now." >&2
        exit 1
        ;;
    esac
}
main
