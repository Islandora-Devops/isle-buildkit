#!/usr/bin/with-contenv bash

# Capitalize the given string.
function capitalize {
    local string="${1}"; shift
    echo $(tr '[:lower:]' '[:upper:]' <<< ${string:0:1})$(tr '[:upper:]' '[:lower:]' <<< ${string:1})
}

# Transform the given string to uppercase.
function uppercase {
    local string="${1}"; shift
    echo $(tr '[:lower:]' '[:upper:]' <<< ${string})
}

# Joins the given array into a string delimited by the first argument.
function join_by {
    local IFS="${1}"; shift
    echo "$*"
}

# Get variable value for given site.
function drupal_site_env {
    local site="$(uppercase ${1})"; shift
    local suffix="$(uppercase ${1})"; shift
    local var=
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
    local site="${1}"; shift
    local array=(${DRUPAL_SITES})
    for i in "${!array[@]}"; do
        if [[ "${array[$i]}" = "${site}" ]]; then
            echo "${i}";
            return 0
        fi
    done
    # Should be unreachable under normal use.
    exit 1
}

# Wait for service to respond.
function wait_for_service {
    local site="${1}"; shift
    local service="${1}"; shift
    local time="${1-300}";
    local host=$(drupal_site_env "${site}" "${service}_HOST")
    local port=$(drupal_site_env "${site}" "${service}_PORT")
    local service_name=$(capitalize "${service}")

    if timeout ${time} wait-for-open-port.sh "${host}" "${port}" ; then
        echo "${service_name} Found at ${host}:${port}"
        return 0
    else
        echo "Could not connect to ${service_name} at ${host}:${port}"
        exit 1
    fi
}

# Waits for services that are required to be running to successfully ingest content.
function wait_for_required_services {
    local site="${1}"; shift
    if [ $# -gt 0 ]; then
        while [ $# -gt 0 ]; do
            local service="${1}"; shift
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
    local function="${1}"; shift
    local n=$(nproc)
    local pids=()
    for site in ${DRUPAL_SITES}; do
        $function "${site}" ${@} &
        pids+=(${!})
        # Allow only to execute ${n} jobs in parallel
        if [[ $(jobs -r -p | wc -l) -gt ${n} ]]; then
            # Wait only for first job, exit code here will propigate
            wait -n
        fi
    done
    # To ensure the exit code propigates we must wait for each process individually
    for pid in ${pids[@]}; do
        wait "${pid}"
    done
}

function execute_sql_file {
    local site="${1}"; shift
    local driver=$(drupal_site_env "${site}" "DB_DRIVER")
    local host=$(drupal_site_env "${site}" "DB_HOST")
    local port=$(drupal_site_env "${site}" "DB_PORT")
    local user=$(drupal_site_env "${site}" "DB_ROOT_USER")
    local password=$(drupal_site_env "${site}" "DB_ROOT_PASSWORD")
    execute-sql-file.sh \
        --driver "${driver}" \
        --host "${host}" \
        --port "${port}" \
        --user "${user}" \
        --password "${password}" \
        "${@}"
}

function mysql_query {
    local site="${1}"; shift
    local db_name=$(drupal_site_env "${site}" "DB_NAME")
    local db_user=$(drupal_site_env "${site}" "DB_USER")
    local db_password=$(drupal_site_env "${site}" "DB_PASSWORD")
    cat <<- EOF
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
    local site="${1}"; shift
    execute_sql_file "${site}" <(mysql_query "${site}")
}

function postgres_query {
    local site="${1}"; shift
    local db_name=$(drupal_site_env "${site}" "DB_NAME")
    local db_user=$(drupal_site_env "${site}" "DB_USER")
    local db_password=$(drupal_site_env "${site}" "DB_PASSWORD")
    cat <<- EOF
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
    local site="${1}"; shift
    local db_name=$(drupal_site_env "${site}" "DB_NAME")
    execute_sql_file "${site}" --database "${db_name}" <(echo 'select 1')
}

function postgresql_create_database {
    local site="${1}"; shift
    local db_name=$(drupal_site_env "${site}" "DB_NAME")
    # Postgres does not support CREATE DATABASE IF NOT EXISTS so split our logic across multiple queries.
    if ! postgresql_database_exists "${site}"; then
        execute_sql_file "${site}" <(echo "CREATE DATABASE ${db_name}")
    fi
    execute_sql_file "${site}" --database "${db_name}" <(postgres_query "${site}")
}

# Create a database for the given site.
function create_database {
    local site="${1}"; shift
    local driver=$(drupal_site_env "${site}" "DB_DRIVER")
    
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
    esac
}

# Install the given site.
function install_site {
    local site="${1}"; shift
    local drupal_root=$(drush drupal:directory)
    local driver=$(drupal_site_env "${site}" "DB_DRIVER")
    local host=$(drupal_site_env "${site}" "DB_HOST")
    local port=$(drupal_site_env "${site}" "DB_PORT")
    local user=$(drupal_site_env "${site}" "DB_USER")
    local password=$(drupal_site_env "${site}" "DB_PASSWORD")
    local db_name=$(drupal_site_env "${site}" "DB_NAME")
    local account_email=$(drupal_site_env "${site}" "ACCOUNT_EMAIL")
    local account_name=$(drupal_site_env "${site}" "ACCOUNT_NAME")
    local account_password=$(drupal_site_env "${site}" "ACCOUNT_PASSWORD")
    local profile=$(drupal_site_env "${site}" "PROFILE")
    local site_email=$(drupal_site_env "${site}" "EMAIL")
    local site_locale=$(drupal_site_env "${site}" "LOCALE")
    local site_name=$(drupal_site_env "${site}" "NAME")
    local subdir=$(drupal_site_env "${site}" "SUBDIR")
    local site_directory=$(realpath "${drupal_root}/sites/${subdir}")
    local files_directory=$(realpath "${site_directory}/files")
    local install=$(drupal_site_env "${site}" "INSTALL")
    local use_existing_config=$(drupal_site_env "${site}" "INSTALL_EXISTING_CONFIG")
    local use_existing_config_arg=

    if [ "${install}" != "true" ]; then
        echo "Skipping install of site: $(capitalize ${site})"
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
    if [[ -f "${site_directory}/settings.php" ]]; then
        chmod a=rwx "${site_directory}/settings.php"
    fi

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
        ${@}

    # Restrict changes to settings.php
    if [[ -f "${site_directory}/settings.php" ]]; then
        chmod a=,ug=r "${site_directory}/settings.php"
    fi
}

# Get the base url of fedora.
function fedora_url {
    local site="${1}"; shift
    local fcrepo_host=$(drupal_site_env "${site}" "FCREPO_HOST")
    local fcrepo_port=$(drupal_site_env "${site}" "FCREPO_PORT")

    # Indexing fails if port 80 is given explicitly.
    if [[ "${fcrepo_port}" == "80" ]]; then
        echo "http://${fcrepo_host}/fcrepo/rest/"
    else
        echo "http://${fcrepo_host}:${fcrepo_port}/fcrepo/rest/"
    fi
}

# Regenerate / Update settings.php
function update_settings_php {
    local site="${1}"; shift
    local drupal_root=$(drush drupal:directory)
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    local driver=$(drupal_site_env "${site}" "DB_DRIVER")
    local host=$(drupal_site_env "${site}" "DB_HOST")
    local port=$(drupal_site_env "${site}" "DB_PORT")
    local user=$(drupal_site_env "${site}" "DB_USER")
    local password=$(drupal_site_env "${site}" "DB_PASSWORD")
    local db_name=$(drupal_site_env "${site}" "DB_NAME")
    local config_dir=$(drupal_site_env "${site}" "CONFIGDIR")
    local fcrepo_host=$(drupal_site_env "${site}" "FCREPO_HOST")
    local fcrepo_port=$(drupal_site_env "${site}" "FCREPO_PORT")
    local salt=$(drupal_site_env "${site}" "SALT")
    local subdir=$(drupal_site_env "${site}" "SUBDIR")
    local site_directory=$(realpath "${drupal_root}/sites/${subdir}")
    local install=$(drupal_site_env "${site}" "INSTALL")
    local fedora_url=$(fedora_url "${site}")
    local previous_owner_group=

    if [ "${install}" != "true" ]; then
        echo "Skipping update of settings.php for site: $(capitalize "${site}")"
        return 0
    fi

    # Allow modifications to settings.php
    if [ -f "${site_directory}/settings.php" ]; then
        previous_owner_group=$(stat -c "%u:%g" "${site_directory}/settings.php")
        chown 100:101 "${site_directory}/settings.php"
        chmod a=rwx "${site_directory}/settings.php"
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
    if [ ! -z "${config_dir}" ]; then
        drush -l "${site_url}" islandora:settings:set-config-sync-directory ${config_dir}
    fi

    # Restore owner/group to previous value
    if [ ! -z "${previous_owner_group}" ]; then
        chown "${previous_owner_group}" "${site_directory}/settings.php"
    fi

    # Restrict access to settings.php
    chmod 444 "${site_directory}/settings.php"
}

# Enable module and apply configuration.
function configure_jwt_module {
    local site="${1}"
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l "${site_url}" -y pm:enable jwt
    drush -l "${site_url}" -y config:import --partial --source=/etc/islandora/configs/jwt
}

# Install and configure the islandora module.
function configure_islandora_module {
    local site="${1}"; shift
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    local broker_host=$(drupal_site_env "${site}" "BROKER_HOST")
    local broker_port=$(drupal_site_env "${site}" "BROKER_PORT")
    local broker_url="tcp://${broker_host}:${broker_port}"

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

# After enabling and importing features a number of configurations need to be updated.
function configure_islandora_default_module {
    if ! drush pm-list --pipe --type=module --status=enabled --no-core | grep -q islandora_defaults; then
        echo "islandora_defaults is not installed.  Skipping configuration"
        return 0
    fi

    local site="${1}"; shift
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    local host=$(drupal_site_env "${site}" "SOLR_HOST")
    local port=$(drupal_site_env "${site}" "SOLR_PORT")

    drush -l "${site_url}" -y config:set search_api.server.default_solr_server backend_config.connector_config.host "${host}"
    drush -l "${site_url}" -y config:set search_api.server.default_solr_server backend_config.connector_config.port "${port}"
}

# Install search_api_solr and configure. Also uninstall the default search module.
function configure_search_api_solr_module {
    local site="${1}"; shift
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    local driver=$(drupal_site_env "${site}" "DB_DRIVER")

    drush -l "${site_url}" -y pm:enable search_api_solr

    # Currently a bug when using PostgreSQL that disallows unintalling this module.
    if [ "${driver}" != "pgsql" ]; then
        drush -l "${site_url}" -y pm:uninstall search
    fi
}

# Enables and sets carapace as the default theme.
function set_carapace_default_theme {
    if ! drush pm-list --pipe --type=theme --status=enabled --no-core | grep -q carapace; then
        echo "carapace is not available. Skipping configuration."
        return 0
    fi

    local site="${1}"; shift
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l "${site_url}" -y config:set system.theme default carapace
}

# Generate solr config using the search_api_solr module.
#
# Assumes the search_api_solr module has already been installed.
# Assumes that the destination will be a shared volume.
function generate_solr_config {
    local site="${1}"; shift
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    local core=$(drupal_site_env "${site}" "SOLR_CORE")
    local dest="${1-/opt/solr/server/solr/${core}}";

    mkdir -p "/tmp/${core}" || true
    chmod a+rwx "/tmp/${core}"
    drush -l "${site_url}" -y search-api-solr:get-server-config default_solr_server "/tmp/${core}/solr_config.zip" 7.1
    mkdir -p "${dest}/conf" || true
    mkdir -p "${dest}/data" || true
    unzip -o "/tmp/${core}/solr_config.zip" -d "${dest}/conf"

    # The uid:gid "100:1000" is "solr:solr" inside of the solr container.
    chown -R 100:1000 "${dest}"
}

# Creates a SOLR core for the site using the Solr REST API.
function create_solr_core {
    local site="${1}"; shift
    local core=$(drupal_site_env "${site}" "SOLR_CORE")
    local host=$(drupal_site_env "${site}" "SOLR_HOST")
    local port=$(drupal_site_env "${site}" "SOLR_PORT")

    # Require a running Solr to create a core.
    wait_for_service "${site}" "SOLR"

    curl -s "http://${host}:${port}/solr/admin/cores?action=CREATE&name=${core}&instanceDir=${core}&config=solrconfig.xml&dataDir=data" &> /dev/null
}

# Generate solr config and create a core for it.
function create_solr_core_with_default_config {
    if ! drush pm-list --pipe --type=module --status=enabled --no-core | grep -q search_api_solr; then
        echo "search_api_solr is not installed.  Skipping core setup."
        return 0
    fi

    local site="${1}"; shift
    generate_solr_config "${site}"
    create_solr_core "${site}"
}

# Install matomo and configure.
function configure_matomo_module {
    if ! drush pm-list --pipe --type=module --status=enabled --no-core | grep -q matomo; then
        echo "matomo is not installed.  Skipping configuration"
        return 0
    fi

    local site="${1}"; shift
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    local site_id=$(($(site_index "${site}")+1))
    local matomo_url=$(drupal_site_env "${site}" "MATOMO_URL")
    local matomo_http_url="http${matomo_url#https}"

    drush -l "${site_url}" -y config-set matomo.settings site_id "${site_id}"
    drush -l "${site_url}" -y config-set matomo.settings url_http "${matomo_http_url}"
    drush -l "${site_url}" -y config-set matomo.settings url_https "${matomo_url}"
}

# Configure Openseadragon to point use cantaloupe.
function configure_openseadragon  {
    if ! drush pm-list --pipe --type=module --status=enabled --no-core | grep -q openseadragon; then
        echo "openseadragon is not installed.  Skipping configuration"
        return 0
    fi

    local site="${1}"; shift
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    local cantaloupe_url=$(drupal_site_env "${site}" "CANTALOUPE_URL")

    drush -l "${site_url}" -y config-set --input-format=yaml media.settings standalone_url true
    drush -l "${site_url}" -y config-set --input-format=yaml openseadragon.settings iiif_server "${cantaloupe_url}"
    drush -l "${site_url}" -y config-set --input-format=yaml openseadragon.settings manifest_view iiif_manifest
    drush -l "${site_url}" -y config-set --input-format=yaml islandora_iiif.settings iiif_server "${cantaloupe_url}"
}

# Imports any migrations in the 'islandora' group.
function import_islandora_migrations {
    local site="${1}"; shift
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l "${site_url}" -y --userid=1 migrate:import --group=islandora
}

# Enable module and apply configuration.
function enable_modules {
    local site="${1}"; shift
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l "${site_url}" -y pm:enable ${@}
}

# Enable module and apply configuration.
function import_features {
    local site="${1}"; shift
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    local features=$(join_by , ${@}); shift
    drush -l "${site_url}" fim --no-interaction --yes "${features}"
}

# Rebuild the cache for the given site.
function cache_rebuild {
    local site="${1}"; shift
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l "${site_url}" -y cache:rebuild
}

# Changes the site ID to match the configuration folder to allow it to be imported.
function set_site_uuid {
    local site="${1}"; shift
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    local drupal_root=$(drush drupal:directory)
    local config_dir=$(cd $drupal_root; realpath `drush php:eval "echo \Drupal\Core\Site\Settings::get('config_sync_directory');"`) # Handle the case if config_dir is a relative path.
    local uuid=${1-$(cat ${config_dir}/system.site.yml  | awk '/uuid/ { print $2 }')}
    drush -l ${site_url} -y config:set --input-format=yaml system.site uuid ${uuid}
}

# Replace references to standard profile in the config files with minimal.
# 
# Often we build sites with the standard profile but it is not possible to install 
# from a configuration that was generated on a standard profile site.
#
# https://www.drupal.org/project/drupal/issues/2982052
function remove_standard_profile_references_from_config {
    # Do not modify configuration in in the core module.
    local config_files=$(find /var/www/drupal -name "core.extension.yml" ! -path '*/core/*')
    for config_file in ${config_files}; do
        # Remove standard profile references, and replace with minimal.
        sed -i 's|\( *\)standard:\(.*\)|\1minimal:\2|' ${config_file}
        sed -i 's|profile: *standard|profile: minimal|' ${config_file}
    done
}

# Import sites configuration.
function import_config {
    local site="${1}"
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l ${site_url} -y config:import
}

# Export sites configuration.
function export_config {
    local site="${1}"
    local site_url=$(drupal_site_env "${site}" "SITE_URL")
    drush -l ${site_url} -y config:export
}

# Generates blazegraph properties for the given site using its namespace.
function default_blazegraph_properties {
    local site="${1}"; shift
    local namespace=$(drupal_site_env "${site}" "TRIPLESTORE_NAMESPACE")
    cat <<- EOF
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
    local site="${1}"; shift
    local properties_file="${1}"; shift
    local host=$(drupal_site_env "${site}" "TRIPLESTORE_HOST")
    local port=$(drupal_site_env "${site}" "TRIPLESTORE_PORT")
    local namespace=$(drupal_site_env "${site}" "TRIPLESTORE_NAMESPACE")
    local triplestore_url="http://${host}:${port}/bigdata"

    # Require a running blazegraph to update it.
    wait_for_service "${site}" "TRIPLESTORE"

    # Setup namespace / inference for the given namespace.
    curl -X POST -H "Content-type: text/plain" --data-binary "@${properties_file}" "${triplestore_url}/namespace"
    curl -X POST -H "Content-type: text/plain" --data-binary @/etc/islandora/configs/inference.nt "${triplestore_url}/namespace/${namespace}/sparql"
}

# Create a namespace with default properties for the given site.
function create_blazegraph_namespace_with_default_properties {
    local site="${1}"; shift
    create_blazegraph_namespace "${site}" <(default_blazegraph_properties "${site}")
}
