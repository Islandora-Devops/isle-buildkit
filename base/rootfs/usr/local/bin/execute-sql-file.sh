#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME options FILE

    Executes the given SQL file against the appropriate driver.

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

function cmdline {
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            # Translate --gnu-long-options to -g (short options)
            --driver)      args="${args}-a ";;
            --host)        args="${args}-b ";;
            --port)        args="${args}-c ";;
            --user)        args="${args}-d ";;
            --password)    args="${args}-e ";;
            --database)    args="${args}-f ";;
            --help)        args="${args}-h ";;
            --debug)       args="${args}-x ";;
            # Pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done

    # Reset the positional parameters to the short options
    eval set -- $args

    while getopts "a:b:c:d:e:f:hx" OPTION
    do
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
            readonly DATABASE=${OPTARG}
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

    if [[ -z $DRIVER || -z $HOST || -z $PORT || -z $USER || -z $PASSWORD ]]; then
        echo "Missing one of required options: --driver --host --port --user --password" >&2
        exit 1
    fi

    shift $((OPTIND-1))

    if [ "$#" -lt 1 ]; then
      echo "Illegal number of parameters" >&2
      usage
      return 1
    fi

    readonly FILE="${1}"; shift

    # Remaining options to be passed onto the client, preceeded by '--'.
    if [ "$#" -gt 0 ]; then
        shift;
        readonly OPTIONS=(${@}); shift $#
    else
        readonly OPTIONS=()
    fi

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

    if [[ ! -z "${DATABASE}" ]]; then
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
        < "${FILE}"
}

function postgresql_execute_sql_file {
    local database_arg="--dbname=postgres"

    if [[ ! -z "${DATABASE}" ]]; then
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
        mysql|pdo_mysql|mariadb)
            mysql_execute_sql_file
            ;;
        pgsql|postgresql|pdo_pgsql)
            postgresql_execute_sql_file
            ;;
        *)
            echo "Only MySQL/PostgresSQL databases are supported for now." >&2
            exit 1
    esac
}

function main {
    cmdline ${ARGS}
    wait_for_access
    execute_sql_file
}
main
