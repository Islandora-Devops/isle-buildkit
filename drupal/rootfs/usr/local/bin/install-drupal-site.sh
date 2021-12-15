#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME options [DRUSH_ARGS]

    Install a Drupal site with the given [DRUSH_ARGS].

    OPTIONS:
       --driver           The database driver.
       --host             The database host.
       --port             The database port.
       --db-user             The user to connect as.
       --db-password         The password to use for the user.
       --db-name          The name of the database to install into.

       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Install default Drupal site:
       $PROGNAME \\
                --driver "mysql" \\
                --host "mariadb" \\
                --port "3306" \\
                --db-user "root" \\
                --db-password "password" \\
                --db-name "drupal_default" \\
                standard --sites-subdir=default --site-name=Islandora
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
            --db-user)     args="${args}-d ";;
            --db-password) args="${args}-e ";;
            --db-name)     args="${args}-f ";;
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
            readonly DB_USER=${OPTARG}
            ;;
        e)
            readonly DB_PASSWORD=${OPTARG}
            ;;
        f)
            readonly DB_NAME=${OPTARG}
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

    if [[ -z $DRIVER || -z $HOST || -z $PORT || -z $DB_USER || -z $DB_PASSWORD || -z $DB_NAME ]]; then
        echo "Missing one of required options: --host --port --db-user --db-password --db-name"
        exit 1
    fi

    # All remaning parameters are passed to 'drush site-install'.
    shift $((OPTIND-1))
    readonly DRUSH_ARGS="$@"

    return 0
}

function execute_sql_file {
    execute-sql-file.sh \
        --driver "${DRIVER}" \
        --host "${HOST}" \
        --port "${PORT}" \
        --user "${DB_USER}" \
        --password "${DB_PASSWORD}" \
        "${@}"
}

function mysql_count_query {
    cat <<- EOF
SELECT COUNT(DISTINCT table_name)
FROM information_schema.columns
WHERE table_schema = '${DB_NAME}';
EOF
}

function mysql_count {
    execute_sql_file <(mysql_count_query) -- -N 2>/dev/null
}

function postgresql_count_query {
    cat <<- EOF
SELECT count(*)
FROM information_schema.tables
WHERE table_schema = 'public';
EOF
}

function postgresql_count {
    execute_sql_file --database ${DB_NAME} <(postgresql_count_query) -- -t 2>/dev/null
}

# Check the number of tables to determine if it has already been installed.
function installed {
    local count=
    case "${DRIVER}" in
        mysql)
            count=$(mysql_count)
            ;;
        postgresql)
            count=$(postgresql_count)
            ;;
        *)
            echo "Only MySQL/PostgresSQL databases are supported for now." >&2
            exit 1
    esac
    [[ $count -ne 0 ]]
}

function main {
    cmdline ${ARGS}
    local protocol=mysql
    if installed; then
        echo "Site already is installed."
        return 0
    fi
    if [[ "${DRIVER}" == "postgresql" ]]; then
        protocol=pgsql
    fi
    echo "Installing site."
    drush \
        -n \
        si ${DRUSH_ARGS} \
        --db-url="${protocol}://${DB_USER}:${DB_PASSWORD}@${HOST}:${PORT}/${DB_NAME}"
}
main
