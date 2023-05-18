#!/usr/bin/env bash
set -e
ARGS=("$@")
PROGNAME=$(basename "$0")
readonly ARGS PROGNAME

function usage {
    cat <<-EOF
    usage: $PROGNAME options FILE

    With no FILE, or when FILE is -, read standard input.

    Executes the given SQL file against the appropriate driver.

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
       --database         The database to run the sql command against. (Optional)
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Create a database:
       $PROGNAME \\
                --driver "mysql" \\
                --host "mariadb" \\
                --port "3306" \\
                --user "root" \\
                --password "password" query.sql
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
            DRIVER=${OPTARG}
            ;;
        b)
            HOST=${OPTARG}
            ;;
        c)
            PORT=${OPTARG}
            ;;
        d)
            USER=${OPTARG}
            ;;
        e)
            PASSWORD=${OPTARG}
            ;;
        f)
            DATABASE=${OPTARG}
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

    if fallback "--user" "USER" "DB_ROOT_USER"; then
        USER=${DB_ROOT_USER}
    fi

    if fallback "--password" "PASSWORD" "DB_ROOT_PASSWORD"; then
        PASSWORD=${DB_ROOT_PASSWORD}
    fi

    if fallback "--driver" "DRIVER" "DB_DRIVER"; then
        DRIVER=${DB_DRIVER}
    fi

    if fallback "--host" "HOST" "DB_HOST"; then
        HOST=${DB_HOST}
    fi

    if fallback "--port" "PORT" "DB_PORT"; then
        PORT=${DB_PORT}
    fi

    shift $((OPTIND - 1))

    # Allow either passing in a file or reading from stdin by specifiying "-" or
    # ommiting completely.
    if [[ -f "${1}" || -p "${1}" ]]; then
        FILE="${1}"
        shift
    elif [[ "${1}" == "-" ]]; then
        FILE=/dev/stdin
        shift
    else
        FILE=/dev/stdin
    fi

    # Remaining options to be passed onto the client, preceeded by '--'.
    if [[ "${1}" == "--" ]]; then
        shift
    fi

    if [ "$#" -gt 0 ]; then
        OPTIONS=("${@}")
        shift $#
    else
        OPTIONS=()
    fi

    readonly DRIVER HOST PORT USER PASSWORD DATABASE FILE OPTIONS

    return 0
}

function wait_for_access {
    # Redirect all output to 'stderr' so that this can be called to do count queries, etc.
    # Callers can extract the value from the appropriate value from 'stdout'.
    wait-for-database.sh \
        --driver "${DRIVER}" \
        --host "${HOST}" \
        --port "${PORT}" \
        --user "${USER}" \
        --password "${PASSWORD}" >&2
}

function mysql_execute_sql_file {
    local database_arg=

    if [[ -n "${DATABASE}" ]]; then
        database_arg="--database=${DATABASE}"
    fi

    mysql \
        --host="${HOST}" \
        --port="${PORT}" \
        --user="${USER}" \
        --password="${PASSWORD}" \
        --protocol=tcp \
        "${database_arg}" \
        "${OPTIONS[@]}" \
        <"${FILE}"
}

function postgresql_execute_sql_file {
    local database_arg="--dbname=postgres"

    if [[ -n "${DATABASE}" ]]; then
        database_arg="--dbname=${DATABASE}"
    fi

    PGPASSWORD="${PASSWORD}" psql \
        -v ON_ERROR_STOP=1 \
        --host="${HOST}" \
        --port="${PORT}" \
        --username="${USER}" \
        "${database_arg}" \
        -f "${FILE}" \
        "${OPTIONS[@]}"
}

function execute_sql_file {
    case "${DRIVER}" in
    mysql)
        mysql_execute_sql_file
        ;;
    postgresql)
        postgresql_execute_sql_file
        ;;
    *)
        echo "Only MySQL/PostgresSQL databases are supported for now." >&2
        exit 1
        ;;
    esac
}

function main {
    cmdline "${ARGS[@]}"
    wait_for_access
    execute_sql_file
}
main
