#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME options

    Creates a database for the given Drupal the given war into tomcat.

    OPTIONS:
       --driver           The database driver.
       --host             The database host.
       --port             The database port.
       --user             The user to connect as.
       --password         The password to use for the user.
       --db-name          The name of the newly created database.
       --db-user          The user for managing the newly created database.
       --db-password      The password of the user.

       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Create a Drupal database for the default site:
       $PROGNAME \\
                --driver "mysql" \\
                --host "database" \\
                --port "3306" \\
                --user "root" \\
                --password "password" \\
                --db-name "drupal_default" \\
                --db-user "drupal_default" \\
                --db-password "password"
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
            --db-name)     args="${args}-f ";;
            --db-user)     args="${args}-g ";;
            --db-password) args="${args}-i ";;
            --help)        args="${args}-h ";;
            --debug)       args="${args}-x ";;
            # Pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done

    # Reset the positional parameters to the short options
    eval set -- $args

    while getopts "a:b:c:d:e:f:g:i:hx" OPTION
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
            readonly ROOT_USER=${OPTARG}
            ;;
        e)
            readonly ROOT_PASSWORD=${OPTARG}
            ;;
        f)
            readonly DB_NAME=${OPTARG}
            ;;
        g)
            readonly DB_USER=${OPTARG}
            ;;
        i)
            readonly DB_PASS=${OPTARG}
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

    if [[ -z $DRIVER || -z $HOST || -z $PORT || -z $ROOT_USER || -z $ROOT_PASSWORD || -z $DB_NAME || -z $DB_USER || -z $DB_PASS ]]; then
        echo "Missing one of required options: --host --port --user --password --db-name --db-user --db-password"
        exit 1
    fi

    return 0
}

function wait_for_access {
    echo "Waiting for connection to database."
    wait-for-mysql.sh \
        --host "${HOST}" \
        --port "${PORT}" \
        --user "${ROOT_USER}" \
        --password "${ROOT_PASSWORD}"
}

# Only create if does not exist, otherwise update user credentials.
function query {
    cat <<- EOF
-- Create if does not exist.
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS ${DB_USER}@'%' IDENTIFIED BY "${DB_PASS}";
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON ${DB_NAME}.* to ${DB_USER}@'%' IDENTIFIED BY "${DB_PASS}";
FLUSH PRIVILEGES;

-- Update DB_USER password if changed.
SET PASSWORD FOR ${DB_USER}@'%' = PASSWORD('${DB_PASS}');
EOF
}

function create_database {
    echo "Create database '${DB_NAME}' and users if they do not exist."
    mysql \
        --host="${HOST}" \
        --port="${PORT}" \
        --user="${ROOT_USER}" \
        --password="${ROOT_PASSWORD}" \
        --protocol=tcp \
        -e "$(query)"
}

function main {
    cmdline ${ARGS}

    if [[ "${DRIVER}" == "mysql" ]]; then
        wait_for_access
        create_database
    else
      echo "Only MySQL databases are supported for now."
      exit 1
    fi
}
main
