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
       --user             The user to connect as.
       --password         The password to use for the user.
       --db-name          The name of the database to install into.

       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Install default Drupal site:
       $PROGNAME \\
                --driver "mysql" \\
                --host "database" \\
                --port "3306" \\
                --user "root" \\
                --password "password" \\
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
            --driver)     args="${args}-a ";;
            --host)       args="${args}-b ";;
            --port)       args="${args}-c ";;
            --user)       args="${args}-d ";;
            --password)   args="${args}-e ";;
            --db-name)    args="${args}-f ";;
            --help)       args="${args}-h ";;
            --debug)      args="${args}-x ";;
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
            readonly ROOT_USER=${OPTARG}
            ;;
        e)
            readonly ROOT_PASSWORD=${OPTARG}
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

    if [[ -z $DRIVER || -z $HOST || -z $PORT || -z $ROOT_USER || -x $ROOT_PASSWORD ]]; then
        echo "Missing one of required options: --host --port --user --password"
        exit 1
    fi

    # All remaning parameters are passed to 'drush site-install'.
    shift $((OPTIND-1))
    readonly DRUSH_ARGS="$@"

    return 0
}

function count_query {
    cat <<- EOF
SELECT COUNT(DISTINCT table_name)
FROM information_schema.columns
WHERE table_schema = '${DB_NAME}';
EOF
}

function installed {
    # Check the number of tables to determine if it has already been installed.
    local count=$(mysql \
        --user="${ROOT_USER}" \
        --password="${ROOT_PASSWORD}" \
        --host="${HOST}" \
        --port="${PORT}" \
        --protocol=tcp \
        -Ne "$(count_query)")
    [[ $count -ne 0 ]]
}

function main {
    cmdline ${ARGS}

    if installed; then
        echo "Site already is installed."
        return 0
    fi
    echo "Installing site."
    s6-setuidgid nginx drush \
        -n \
        si ${DRUSH_ARGS} \
        --db-url="${DRIVER}://${ROOT_USER}:${ROOT_PASSWORD}@${HOST}:${PORT}/${DB_NAME}"
}
main
