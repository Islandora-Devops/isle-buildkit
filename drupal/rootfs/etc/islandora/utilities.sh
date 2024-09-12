#!/command/with-contenv bash
# shellcheck shell=bash

# Capitalize the given string.
function capitalize {
    local string="${1}"
    shift
    awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}' <<<"${string}"
}

# Transform the given string to uppercase.
function uppercase {
    local string="${1}"
    shift
    tr '[:lower:]' '[:upper:]' <<<"${string}"
}

# Joins the given array into a string delimited by the first argument.
function join_by {
    local IFS="${1}"
    shift
    echo "$*"
}

# Get variable value for given site.
function drupal_site_env {
    local site suffix var
    site="$(uppercase "${1}")"
    shift
    suffix="$(uppercase "${1}")"
    shift
    if [ "${site}" = "DEFAULT" ]; then
        var="DRUPAL_DEFAULT_${suffix}"
        echo "${!var}"
    else
        var="DRUPAL_SITE_${site}_${suffix}"
        echo "${!var}"
    fi
}

# Get the index of the given site in the lists of site.
# Useful for generating distinct identifiers.
function site_index {
    local site sites
    site="${1}"
    shift
    sites=("${DRUPAL_SITES[@]}")
    for i in "${!sites[@]}"; do
        if [[ "${sites[$i]}" = "${site}" ]]; then
            echo "${i}"
            return 0
        fi
    done
    # Should be unreachable under normal use.
    exit 1
}

# Wait for service to respond.
function wait_for_service {
    local site service duration host port service_name
    site="${1}"
    shift
    service="${1}"
    shift
    duration="${1-300}"
    host=$(drupal_site_env "${site}" "${service}_HOST")
    port=$(drupal_site_env "${site}" "${service}_PORT")
    service_name=$(capitalize "${service}")

    if timeout "${duration}" wait-for-open-port.sh "${host}" "${port}"; then
        echo "${service_name} Found at ${host}:${port}"
        return 0
    else
        echo "Could not connect to ${service_name} at ${host}:${port}"
        exit 1
    fi
}

# Waits for services that are required to be running to successfully ingest content.
function wait_for_required_services {
    local site
    site="${1}"
    shift
    if [ $# -gt 0 ]; then
        while [ $# -gt 0 ]; do
            local service="${1}"
            shift
            wait_for_service "${site}" "${service}"
        done
    else
        wait_for_service "${site}" "SOLR"
        wait_for_service "${site}" "FCREPO"
        wait_for_service "${site}" "BROKER"
        wait_for_service "${site}" "TRIPLESTORE"
    fi
}

# Apply given function for all sites in parallel, up to the number of cores available.
function for_all_sites {
    local func cpus pids
    func="${1}"
    shift
    cpus=$(nproc)
    pids=()
    for site in ${DRUPAL_SITES}; do
        "${func}" "${site}" "${@}" &
        pids+=(${!})
        # Allow only to execute ${cpu} jobs in parallel
        if [[ $(jobs -r -p | wc -l) -gt ${cpus} ]]; then
            # Wait only for first job, exit code here will propigate
            wait -n
        fi
    done
    # To ensure the exit code propigates we must wait for each process individually
    for pid in "${pids[@]}"; do
        wait "${pid}"
    done
}

function execute_sql_file {
    local site driver host port user password
    site="${1}"
    shift
    driver=$(drupal_site_env "${site}" "DB_DRIVER")
    host=$(drupal_site_env "${site}" "DB_HOST")
    port=$(drupal_site_env "${site}" "DB_PORT")
    user=$(drupal_site_env "${site}" "DB_ROOT_USER")
    password=$(drupal_site_env "${site}" "DB_ROOT_PASSWORD")
    execute-sql-file.sh \
        --driver "${driver}" \
        --host "${host}" \
        --port "${port}" \
        --user "${user}" \
        --password "${password}" \
        "${@}"
}

function mysql_query {
    local site db_name db_user db_password
    site="${1}"
    shift
    db_name=$(drupal_site_env "${site}" "DB_NAME")
    db_user=$(drupal_site_env "${site}" "DB_USER")
    db_password=$(drupal_site_env "${site}" "DB_PASSWORD")
    cat <<-EOF
-- Create if does not exist.
CREATE DATABASE IF NOT EXISTS ${db_name} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS ${db_user}@'%' IDENTIFIED BY "${db_password}";
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES ON ${db_name}.* to ${db_user}@'%' IDENTIFIED BY "${db_password}";
FLUSH PRIVILEGES;

-- Update DB_USER password if changed.
SET PASSWORD FOR ${db_user}@'%' = PASSWORD('${db_password}');
EOF
}

function mysql_create_database {
    local site
    site="${1}"
    shift
    execute_sql_file "${site}" <(mysql_query "${site}")
}

function postgres_query {
    local site db_name db_user db_password
    site="${1}"
    shift
    db_name=$(drupal_site_env "${site}" "DB_NAME")
    db_user=$(drupal_site_env "${site}" "DB_USER")
    db_password=$(drupal_site_env "${site}" "DB_PASSWORD")
    cat <<-EOF
BEGIN;

DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${db_user}') THEN
        CREATE ROLE ${db_user};
    END IF;
END
\$\$;

ALTER ROLE ${db_user} WITH LOGIN;
ALTER USER ${db_user} PASSWORD '${db_password}';

ALTER DATABASE ${db_name} OWNER TO ${db_user};
GRANT ALL PRIVILEGES ON DATABASE ${db_name} TO ${db_user};

COMMIT;
EOF
}

function postgresql_database_exists {
    local site db_name
    site="${1}"
    shift
    db_name=$(drupal_site_env "${site}" "DB_NAME")
    execute_sql_file "${site}" --database "${db_name}" <(echo 'select 1')
}

function postgresql_create_database {
    local site db_name
    site="${1}"
    shift
    db_name=$(drupal_site_env "${site}" "DB_NAME")
    # Postgres does not support CREATE DATABASE IF NOT EXISTS so split our logic across multiple queries.
    if ! postgresql_database_exists "${site}"; then
        execute_sql_file "${site}" <(echo "CREATE DATABASE ${db_name}")
    fi
    execute_sql_file "${site}" --database "${db_name}" <(postgres_query "${site}")
}

# Create a database for the given site.
function create_database {
    local site driver
    site="${1}"
    shift
    driver=$(drupal_site_env "${site}" "DB_DRIVER")

    case "${driver}" in
    mysql)
        mysql_create_database "${site}"
        ;;
    postgresql)
        postgresql_create_database "${site}"
        ;;
    *)
        echo "Only MySQL/PostgresSQL databases are supported for now." >&2
        exit 1
        ;;
    esac
}

# Install the given site.
function install_site {
    local \
        site drupal_root driver host port user password db_name account_email \
        account_name account_password profile site_email site_locale site_name \
        subdir site_directory files_directory install use_existing_config \
        use_existing_config_arg
    site="${1}"
    shift
    drupal_root=/var/www/drupal/web
    driver=$(drupal_site_env "${site}" "DB_DRIVER")
    host=$(drupal_site_env "${site}" "DB_HOST")
    port=$(drupal_site_env "${site}" "DB_PORT")
    user=$(drupal_site_env "${site}" "DB_USER")
    password=$(drupal_site_env "${site}" "DB_PASSWORD")
    db_name=$(drupal_site_env "${site}" "DB_NAME")
    account_email=$(drupal_site_env "${site}" "ACCOUNT_EMAIL")
    account_name=$(drupal_site_env "${site}" "ACCOUNT_NAME")
    account_password=$(drupal_site_env "${site}" "ACCOUNT_PASSWORD")
    profile=$(drupal_site_env "${site}" "PROFILE")
    site_email=$(drupal_site_env "${site}" "EMAIL")
    site_locale=$(drupal_site_env "${site}" "LOCALE")
    site_name=$(drupal_site_env "${site}" "NAME")
    subdir=$(drupal_site_env "${site}" "SUBDIR")
    site_directory=$(realpath "${drupal_root}/sites/${subdir}")
    files_directory=$(realpath "${site_directory}/files")
    install=$(drupal_site_env "${site}" "INSTALL")
    use_existing_config=$(drupal_site_env "${site}" "INSTALL_EXISTING_CONFIG")
    use_existing_config_arg=

    if [ "${install}" != "true" ]; then
        echo "Skipping install of site: $(capitalize "${site}")"
        return 0
    fi

    # Installing from an existing config is optional only works with
    # non-standard profiles. Ones that do not specify an install hook.
    #
    # https://www.drupal.org/node/2897299
    # https://www.drupal.org/project/drupal/issues/2982052
    if [[ "${use_existing_config}" == "true" ]]; then
        use_existing_config_arg="--existing-config"
    fi

    # Ensure the files directory is writable by nginx, as when it is a new volume it is owned by root.
    chown -R 100:101 "${files_directory}"
    chmod -R ug+rw "${files_directory}"

    # Allow changes to settings.php if it exists.
    if [[ -f "${site_directory:?}/settings.php" ]]; then
        chmod a=rwx "${site_directory:?}/settings.php"
    fi

    echo "--driver ${driver}"
    echo "--host ${host}"
    echo "--port ${port}"
    echo "--dbuser ${user}"
    echo "--dbname ${db_name}"
    echo "PROFILE: ${profile}"
    echo "--account-mail=${account_email}"
    echo "--account-name=${account_name}"
    echo "--site-mail=${site_email}"
    echo "--locale=${site_locale}"
    echo "--site-name=${site_name}"
    echo "--sites-subdir=${subdir}"
    echo "USE_EXISTIG_CONFIG: ${use_existing_config_arg}"
    echo "EVERYTHING ELSE: $*"

    /usr/local/bin/install-drupal-site.sh \
        --driver "${driver}" \
        --host "${host}" \
        --port "${port}" \
        --db-user "${user}" \
        --db-password "${password}" \
        --db-name "${db_name}" \
        "${profile}" \
        --account-mail="${account_email}" \
        --account-name="${account_name}" \
        --account-pass="${account_password}" \
        --site-mail="${site_email}" \
        --locale="${site_locale}" \
        --site-name="${site_name}" \
        --sites-subdir="${subdir}" \
        "${use_existing_config_arg}" \
        "${@}"

    # Restrict changes to settings.php
    if [[ -f "${site_directory:?}/settings.php" ]]; then
        chmod a=,ug=r "${site_directory:?}/settings.php"
    fi
}

# Get the base url of fedora.
function fedora_url {
    local site fcrepo_host fcrepo_port
    site="${1}"
    shift
    fcrepo_host=$(drupal_site_env "${site}" "FCREPO_HOST")
    fcrepo_port=$(drupal_site_env "${site}" "FCREPO_PORT")

    # Indexing fails if port 80 is given explicitly.
    if [[ "${fcrepo_port}" == "80" ]]; then
        echo "http://${fcrepo_host}/fcrepo/rest/"
    else
        echo "http://${fcrepo_host}:${fcrepo_port}/fcrepo/rest/"
    fi
}

# Allow modifications to settings.php by changing ownership and perms
function allow_settings_modifications {
    local site drupal_root subdir site_directory
    site="${1}"
    shift
    drupal_root=/var/www/drupal/web
    subdir=$(drupal_site_env "${site}" "SUBDIR")
    site_directory=$(realpath "${drupal_root}/sites/${subdir}")

    # send debug output to stderr because the caller typically captures output from this function.
    #>&2 echo "adjusting ownership of "${site_directory:?}/settings.php""
    if [ -f "${site_directory:?}/settings.php" ]; then
        previous_owner_group=$(stat -c "%u:%g" "${site_directory:?}/settings.php")
        chown 100:101 "${site_directory:?}/settings.php"
        chmod a=rwx "${site_directory:?}/settings.php"
    fi
    if [ -n "${previous_owner_group}" ]; then
        echo "${previous_owner_group}"
    fi
}

# Restore ownership of settings.php so that it is readable/writable outside of docker
function restore_settings_ownership {
    local site previous_owner_group drupal_root subdir site_directory
    site="${1}"
    shift
    previous_owner_group="${1}"
    shift
    drupal_root=/var/www/drupal/web
    subdir=$(drupal_site_env "${site}" "SUBDIR")
    site_directory=$(realpath "${drupal_root}/sites/${subdir}")

    # Restore owner/group to previous value.
    # When the codebase is bind-mounted, this ensures the file remains readable/writable by the host user.
    if [ -n "${previous_owner_group}" ]; then
        chown "${previous_owner_group}" "${site_directory:?}/settings.php"
    fi

    # Restrict access to settings.php
    chmod 444 "${site_directory:?}/settings.php"
}

# Regenerate / Update settings.php
function update_settings_php {
    local \
        site drupal_root site_url driver host port user password db_name \
        config_dir fcrepo_host fcrepo_port salt subdir site_directory install \
        fedora_url previous_owner_group
    site="${1}"
    shift
    drupal_root=/var/www/drupal/web
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    driver=$(drupal_site_env "${site}" "DB_DRIVER")
    host=$(drupal_site_env "${site}" "DB_HOST")
    port=$(drupal_site_env "${site}" "DB_PORT")
    user=$(drupal_site_env "${site}" "DB_USER")
    password=$(drupal_site_env "${site}" "DB_PASSWORD")
    db_name=$(drupal_site_env "${site}" "DB_NAME")
    config_dir=$(drupal_site_env "${site}" "CONFIGDIR")
    fcrepo_host=$(drupal_site_env "${site}" "FCREPO_HOST")
    fcrepo_port=$(drupal_site_env "${site}" "FCREPO_PORT")
    salt=$(drupal_site_env "${site}" "SALT")
    subdir=$(drupal_site_env "${site}" "SUBDIR")
    site_directory=$(realpath "${drupal_root}/sites/${subdir}")
    install=$(drupal_site_env "${site}" "INSTALL")
    fedora_url=$(fedora_url "${site}")

    if [ "${install}" != "true" ]; then
        echo "Skipping update of settings.php for site: $(capitalize "${site}")"
        return 0
    fi

    # Allow modifications to settings.php
    previous_owner_group=$(allow_settings_modifications "${site}")

    # shellcheck disable=SC2016
    if ! grep -q 'global $content_directories;' "${site_directory:?}/settings.php"; then
        echo 'global $content_directories;' >>"${site_directory:?}/settings.php"
        echo '$content_directories["sync"] = "/var/www/drupal/content/sync";' >>"${site_directory:?}/settings.php"
    fi

    # shellcheck disable=SC2016
    if ! grep -q 'global $content_directories;' "${site_directory:?}/settings.php"; then
        echo 'global $content_directories;' >>"${site_directory:?}/settings.php"
        echo '$content_directories["sync"] = "/var/www/drupal/content/sync";' >>"${site_directory:?}/settings.php"
    fi

    drush -l "${site_url}" islandora:settings:create-settings-if-missing
    drush -l "${site_url}" islandora:settings:set-hash-salt "${salt}"
    drush -l "${site_url}" islandora:settings:set-flystem-fedora-url "${fedora_url}"
    drush -l "${site_url}" islandora:settings:set-reverse-proxy "${DRUPAL_REVERSE_PROXY_IPS}"
    drush -l "${site_url}" islandora:settings:set-database-settings \
        "${db_name}" \
        "${user}" \
        "${password}" \
        "${host}" \
        "${port}" \
        "${driver}"

    # Specifiying the config_dir is optional, some users will hardcode it in
    # their settings.php so it does not need updating.
    if [ -n "${config_dir}" ]; then
        drush -l "${site_url}" islandora:settings:set-config-sync-directory "${config_dir}"
    fi

    # Restore owner/group to previous value
    restore_settings_ownership "${site}" "${previous_owner_group}"
}

# Enable module and apply configuration.
function configure_jwt_module {
    local site site_url
    site="${1}"
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l "${site_url}" -y pm:enable jwt
    drush -l "${site_url}" -y config:import --partial --source=/etc/islandora/configs/jwt
}

# Install and configure the islandora module.
function configure_islandora_module {
    local site site_url broker_host broker_port broker_url
    site="${1}"
    shift
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    broker_host=$(drupal_site_env "${site}" "BROKER_HOST")
    broker_port=$(drupal_site_env "${site}" "BROKER_PORT")
    broker_url="tcp://${broker_host}:${broker_port}"

    drush -l "${site_url}" -y pm:enable islandora_core_feature
    drush -l "${site_url}" -y config:set --input-format=yaml jsonld.settings remove_jsonld_format true
    drush -l "${site_url}" -y config:set --input-format=yaml islandora.settings broker_url "${broker_url}"

    if drush -l "${site_url}" role:list | grep -q fedoraadmin; then
        echo "Fedora Admin role already exists.  No need to create it."
    else
        drush -l "${site_url}" role:create fedoraadmin fedoraAdmin
    fi
    drush -l "${site_url}" -y user:role:add fedoraadmin admin
}

# Configure Solr port and host.
function configure_islandora_default_module {
    local site site_url host port
    if ! drush pm-list --format=string --type=module --status=enabled --no-core | grep -q search_api; then
        echo "Search API is not installed.  Skipping configuration"
        return 0
    fi
    site="${1}"
    shift
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    host=$(drupal_site_env "${site}" "SOLR_HOST")
    port=$(drupal_site_env "${site}" "SOLR_PORT")

    drush -l "${site_url}" -y config:set search_api.server.default_solr_server backend_config.connector_config.host "${host}"
    drush -l "${site_url}" -y config:set search_api.server.default_solr_server backend_config.connector_config.port "${port}"
}

# Install search_api_solr and configure. Also uninstall the default search module.
function configure_search_api_solr_module {
    local site site_url driver
    site="${1}"
    shift
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    driver=$(drupal_site_env "${site}" "DB_DRIVER")

    drush -l "${site_url}" -y pm:enable search_api_solr

    # Currently a bug when using PostgreSQL that disallows unintalling this module.
    if [ "${driver}" != "pgsql" ]; then
        drush -l "${site_url}" -y pm:uninstall search
    fi
}

# Enables and sets carapace as the default theme.
function set_carapace_default_theme {
    local site site_url
    if ! drush pm-list --format=string --type=theme --status=enabled --no-core | grep -q carapace; then
        echo "carapace is not available. Skipping configuration."
        return 0
    fi

    site="${1}"
    shift
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l "${site_url}" -y config:set system.theme default carapace
}

# Generate solr config using the search_api_solr module.
#
# Assumes the search_api_solr module has already been installed.
# Assumes that the destination will be a shared volume.
function generate_solr_config {
    local site site_url core dest
    site="${1}"
    shift
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    core=$(drupal_site_env "${site}" "SOLR_CORE")
    dest="${1-/opt/solr/server/solr/${core}}"

    mkdir -p "/tmp/${core}" || true
    chmod a+rwx "/tmp/${core}"
    if ! drush -l "${site_url}" -y search-api-solr:get-server-config default_solr_server "/tmp/${core}/solr_config.zip" 9; then
        echo -e "\n\nERROR: Could not generate SOLR config.zip!\nIn Drupal, check Configuration -> Search API -> SOLR Server, and use the\n"+ Get config.zip" option which should give you information into the actual error.\n\n"
        return 1
    fi
    mkdir -p "${dest}/conf" || true
    mkdir -p "${dest}/data" || true
    unzip -o "/tmp/${core}/solr_config.zip" -d "${dest}/conf"

    # The uid:gid "100:1000" is "solr:solr" inside of the solr container.
    chown -R 100:1000 "${dest}"
}

# Creates a SOLR core for the site using the Solr REST API.
function create_solr_core {
    local site core host port
    site="${1}"
    shift
    core=$(drupal_site_env "${site}" "SOLR_CORE")
    host=$(drupal_site_env "${site}" "SOLR_HOST")
    port=$(drupal_site_env "${site}" "SOLR_PORT")

    # Require a running Solr to create a core.
    wait_for_service "${site}" "SOLR"

    curl -s "http://${host}:${port}/solr/admin/cores?action=CREATE&name=${core}&instanceDir=${core}&config=solrconfig.xml&dataDir=data"
}

# Generate solr config and create a core for it.
function create_solr_core_with_default_config {
    local site
    if ! drush pm-list --format=string --type=module --status=enabled --no-core | grep -q search_api_solr; then
        echo "search_api_solr is not installed.  Skipping core setup."
        return 0
    fi

    site="${1}"
    shift
    generate_solr_config "${site}" || return 1
    create_solr_core "${site}"
}

# Install matomo and configure.
function configure_matomo_module {
    local site site_url site_id matomo_url matomo_http_url

    if ! drush pm-list --format=string --type=module --status=enabled --no-core | grep -q matomo; then
        echo "matomo is not installed.  Skipping configuration"
        return 0
    fi

    site="${1}"
    shift
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    site_id=$(($(site_index "${site}") + 1))
    matomo_url=$(drupal_site_env "${site}" "MATOMO_URL")
    matomo_http_url="http${matomo_url#https}"

    drush -l "${site_url}" -y config-set matomo.settings site_id "${site_id}"
    drush -l "${site_url}" -y config-set matomo.settings url_http "${matomo_http_url}"
    drush -l "${site_url}" -y config-set matomo.settings url_https "${matomo_url}"
}

# Configure Openseadragon to point use cantaloupe.
function configure_openseadragon {
    local site site_url cantaloupe_url

    if ! drush pm-list --format=string --type=module --status=enabled --no-core | grep -q openseadragon; then
        echo "openseadragon is not installed.  Skipping configuration"
        return 0
    fi

    site="${1}"
    shift
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    cantaloupe_url=$(drupal_site_env "${site}" "CANTALOUPE_URL")

    drush -l "${site_url}" -y config-set --input-format=yaml media.settings standalone_url true
    drush -l "${site_url}" -y config-set --input-format=yaml openseadragon.settings iiif_server "${cantaloupe_url}"
    drush -l "${site_url}" -y config-set --input-format=yaml openseadragon.settings manifest_view iiif_manifest
    drush -l "${site_url}" -y config-set --input-format=yaml islandora_iiif.settings iiif_server "${cantaloupe_url}"
}

# Imports any migrations in the 'islandora' group.
function import_islandora_migrations {
    local site site_url
    site="${1}"
    shift
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l "${site_url}" -y --userid=1 migrate:import islandora_defaults_tags,islandora_tags
}

# Enable module and apply configuration.
function enable_modules {
    local site site_url
    site="${1}"
    shift
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l "${site_url}" -y pm:enable "${@}"
}

# Enable module and apply configuration.
function import_features {
    local site site_url features
    site="${1}"
    shift
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    features=$(join_by , "${@}")
    shift
    drush -l "${site_url}" fim --no-interaction --yes "${features}"
}

# Rebuild the cache for the given site.
function cache_rebuild {
    local site site_url
    site="${1}"
    shift
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l "${site_url}" -y cache:rebuild
}

# Changes the site ID to match the configuration folder to allow it to be imported.
function set_site_uuid {
    local site site_url drupal_root config_dir uuid
    site="${1}"
    shift
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    drupal_root=/var/www/drupal/web
    # Handle the case if config_dir is a relative path.
    config_dir=$(realpath "$(drush --root="${drupal_root}" php:eval "echo \Drupal\Core\Site\Settings::get('config_sync_directory');")")
    uuid=$(awk '/uuid/ { print $2 }' "${config_dir:?}/system.site.yml")
    drush -l "${site_url}" -y config:set --input-format=yaml system.site uuid "${uuid}"
}

# Replace references to standard profile in the config files with minimal.
#
# Often we build sites with the standard profile but it is not possible to install
# from a configuration that was generated on a standard profile site.
#
# https://www.drupal.org/project/drupal/issues/2982052
function remove_standard_profile_references_from_config {
    local config_files
    # Do not modify configuration in in the core module.
    config_files=$(find /var/www/drupal -name "core.extension.yml" ! -path '*/core/*')
    for config_file in ${config_files}; do
        # Remove standard profile references, and replace with minimal.
        sed -i 's|\( *\)standard:\(.*\)|\1minimal:\2|' "${config_file}"
        sed -i 's|profile: *standard|profile: minimal|' "${config_file}"
    done
}

# Import sites configuration.
function import_config {
    local site site_url
    site="${1}"
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l "${site_url}" -y config:import
}

# Export sites configuration.
function export_config {
    local site site_url
    site="${1}"
    site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l "${site_url}" -y config:export
}

# Generates blazegraph properties for the given site using its namespace.
function default_blazegraph_properties {
    local site namespace
    site="${1}"
    shift
    namespace=$(drupal_site_env "${site}" "TRIPLESTORE_NAMESPACE")
    cat <<-EOF
com.bigdata.rdf.store.AbstractTripleStore.textIndex=false
com.bigdata.rdf.store.AbstractTripleStore.axiomsClass=com.bigdata.rdf.axioms.OwlAxioms
com.bigdata.rdf.sail.isolatableIndices=false
com.bigdata.rdf.store.AbstractTripleStore.justify=true
com.bigdata.rdf.sail.truthMaintenance=true
com.bigdata.rdf.sail.namespace=${namespace}
com.bigdata.rdf.store.AbstractTripleStore.quads=false
com.bigdata.namespace.${namespace}.lex.com.bigdata.btree.BTree.branchingFactor=400
com.bigdata.journal.Journal.groupCommit=false
com.bigdata.namespace.${namespace}.spo.com.bigdata.btree.BTree.branchingFactor=1024
com.bigdata.rdf.store.AbstractTripleStore.geoSpatial=false
com.bigdata.rdf.store.AbstractTripleStore.statementIdentifiers=false
EOF
}

# Create a namespace with the given properties file.
function create_blazegraph_namespace {
    local site properties_file host port namespace triplestore_url
    site="${1}"
    shift
    properties_file="${1}"
    shift
    host=$(drupal_site_env "${site}" "TRIPLESTORE_HOST")
    port=$(drupal_site_env "${site}" "TRIPLESTORE_PORT")
    namespace=$(drupal_site_env "${site}" "TRIPLESTORE_NAMESPACE")
    triplestore_url="http://${host}:${port}/bigdata"

    # Require a running blazegraph to update it.
    wait_for_service "${site}" "TRIPLESTORE"

    # Setup namespace / inference for the given namespace.
    curl -X POST -H "Content-type: text/plain" --data-binary "@${properties_file}" "${triplestore_url}/namespace"
    curl -X POST -H "Content-type: text/plain" --data-binary @/etc/islandora/configs/inference.nt "${triplestore_url}/namespace/${namespace}/sparql"
}

# Create a namespace with default properties for the given site.
function create_blazegraph_namespace_with_default_properties {
    local site="${1}"
    shift
    create_blazegraph_namespace "${site}" <(default_blazegraph_properties "${site}")
}
