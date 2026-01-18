#!/command/with-contenv bash
# shellcheck shell=bash
set -e

# shellcheck disable=SC1091
source /etc/islandora/utilities.sh

readonly SITE="default"

# Only care about derivatives for now.
# As Fedora is slow as beans.
readonly QUEUES=(
    islandora-connector-fits
    islandora-connector-homarus
    islandora-connector-houdini
    islandora-connector-ocr
)

function jolokia {
    local type="${1}"
    local queue="${2}"
    local action="${3}"
    local url="http://${DRUPAL_DEFAULT_BROKER_HOST}:${DRUPAL_DEFAULT_BROKER_WEB_PORT}/api/jolokia/${type}/org.apache.activemq:type=Broker,brokerName=localhost,destinationType=Queue,destinationName=${queue}"
    if [ "$action" != "" ]; then
        url="${url}/$action"
    fi
    curl -s -u "${DRUPAL_DEFAULT_BROKER_WEB_ADMIN_USER}:${DRUPAL_DEFAULT_BROKER_WEB_ADMIN_PASSWORD}" "${url}"
    printf "\n"
}

function wait_for_dequeue {
    local queue_size=-1
    local continue_waiting=1
    while [ "${continue_waiting}" -ne 0 ]; do
        continue_waiting=0
        for queue in "${QUEUES[@]}"; do
            queue_size=$(jolokia "read" "${queue}" | jq .value.QueueSize) &>/dev/null || exit $?
            echo "Queue (${queue}) remaining: ${queue_size}"
            if [ "${queue_size}" != "0" ]; then
                continue_waiting=1
            fi
        done
        sleep 3
    done
}

function configure {
    # Starter site post install steps.
    drush --root=/var/www/drupal --uri="${DRUSH_OPTIONS_URI}" cache:rebuild
    drush --root=/var/www/drupal --uri="${DRUSH_OPTIONS_URI}" user:role:add fedoraadmin admin
    drush --root=/var/www/drupal --uri="${DRUSH_OPTIONS_URI}" pm:uninstall pgsql sqlite
    drush --root=/var/www/drupal --uri="${DRUSH_OPTIONS_URI}" cache:rebuild

    # Ingest sample content.
    drush --root=/var/www/drupal --uri="${DRUSH_OPTIONS_URI}" pm:enable sample_content -y

    # Add check to wait for queue's to empty.
    wait_for_dequeue

    # Add check to wait for solr index to complete.
    drush search-api:index

    # Cache must be last as clearing the cache while adding content can cause deadlocks.
    drush --root=/var/www/drupal --uri="${DRUSH_OPTIONS_URI}" cron || true
    drush --root=/var/www/drupal --uri="${DRUSH_OPTIONS_URI}" cache:rebuild
}

function install {
    wait_for_service "${SITE}" db
    create_database "${SITE}"
    install_site "${SITE}"
    wait_for_service "${SITE}" broker
    wait_for_service "${SITE}" fcrepo
    wait_for_service "${SITE}" fits
    wait_for_service "${SITE}" solr
    wait_for_service "${SITE}" triplestore
    create_blazegraph_namespace_with_default_properties "${SITE}"
    configure
}

function mysql_count_query {
    cat <<-EOF
SELECT COUNT(DISTINCT table_name)
FROM information_schema.columns
WHERE table_schema = '${DRUPAL_DEFAULT_DB_NAME}';
EOF
}

# Check the number of tables to determine if it has already been installed.
function installed {
    local count
    count=$(execute-sql-file.sh <(mysql_count_query) -- -N 2>/dev/null) || exit $?
    [[ $count -ne 0 ]]
}

# Required even if not installing.
function setup() {
    local site drupal_root subdir site_directory public_files_directory private_files_directory twig_cache_directory
    site="${1}"
    shift

    drupal_root=/var/www/drupal/web
    subdir=$(drupal_site_env "${site}" "SUBDIR")
    site_directory="${drupal_root}/sites/${subdir}"
    public_files_directory="${site_directory}/files"
    private_files_directory="/var/www/drupal/private"
    twig_cache_directory="${private_files_directory}/php"

    # Ensure the files directories are writable by nginx, as when it is a new volume it is owned by root.
    mkdir -p "${site_directory}" "${public_files_directory}" "${private_files_directory}" "${twig_cache_directory}"
    chown nginx:nginx "${site_directory}" "${public_files_directory}" "${private_files_directory}" "${twig_cache_directory}"
    chmod ug+rw "${site_directory}" "${public_files_directory}" "${private_files_directory}" "${twig_cache_directory}"
}

function drush_cache_setup {
    # Make sure the default drush cache directory exists and is writeable.
    mkdir -p /tmp/drush-/cache
    chmod a+rwx /tmp/drush-/cache
}

# External processes can look for `/installed` to check if installation is completed.
function finished {
    touch /installed
    cat <<-EOT


#####################
# Install Completed #
#####################
EOT
}

function main() {
    cd /var/www/drupal
    drush_cache_setup
    for_all_sites setup

    if installed; then
        echo "Already Installed"
    else
        echo "Installing"
        install
    fi
    finished
}
main
