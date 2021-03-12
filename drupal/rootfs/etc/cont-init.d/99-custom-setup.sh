#!/usr/bin/with-contenv bash
set -x

if [ -z "${DRUPAL_IGNORE_STARTUP_ERRORS}" ] || [ "${DRUPAL_IGNORE_STARTUP_ERRORS}" != "true" ]; then
  set -e
fi

echo "Executing Islandora setup with the following environment:"
env # cannot pipe through sort, because some vars are multi-line
echo

source /etc/islandora/utilities.sh

function execute_sql_file_local {
    local driver=$(drupal_site_env "${site}" "DB_DRIVER")
    local host=$(drupal_site_env "${site}" "DB_HOST")
    local port=$(drupal_site_env "${site}" "DB_PORT")
    # must be root for the table count query to execute
    local user=root
    local password=${MYSQL_ROOT_PASSWORD}

    /usr/local/bin/execute-sql-file.sh \
        --driver "${driver}" \
        --host "${host}" \
        --port "${port}" \
        --user "${user}" \
        --password "${password}" \
        "${@}"
}

function mysql_count_local {
    echo "SELECT COUNT(DISTINCT table_name)
FROM information_schema.columns
WHERE table_schema = '$(drupal_site_env "${site}" "DB_NAME")';" > /tmp/moo
    execute_sql_file_local /tmp/moo -- -N 2>/dev/null
}

# Check the number of tables to determine if it has already been installed.
function installed_local {
    local count=$(mysql_count_local)
    return $count
}

function enable_maint_mode {
  set_maint_mode $1 1
}

function disable_maint_mode {
  set_maint_mode $1 0
}

function set_maint_mode {
  local site_url=$1
  local mode=$2
  drush -y -l ${site_url} state:set system.maintenance_mode ${mode} --input-format=integer
  drush -y -l ${site_url} cache:rebuild
}

function perform_config_import {
  local site_url=$1
  drush -y -l ${site_url} config:import
}

function configure_islandora_module_local {
  local site="${1}"; shift
  local site_url=$(drupal_site_env "${site}" "SITE_URL")
  local broker_host=$(drupal_site_env "${site}" "BROKER_HOST")
  local broker_port=$(drupal_site_env "${site}" "BROKER_PORT")
  local broker_url="tcp://${broker_host}:${broker_port}"
  local gemini_host=$(drupal_site_env "${site}" "GEMINI_HOST")
  local gemini_port=$(drupal_site_env "${site}" "GEMINI_PORT")
  local gemini_url="http://${gemini_host}:${gemini_port}"

  drush -l "${site_url}" -y config:set --input-format=yaml islandora.settings broker_url "${broker_url}"
  drush -l "${site_url}" -y config:set --input-format=yaml islandora.settings gemini_url "${gemini_url}"
}

function configure_islandora_default_module_local {
  local site="${1}"; shift
  local site_url=$(drupal_site_env "${site}" "SITE_URL")
  local host=$(drupal_site_env "${site}" "SOLR_HOST")
  local port=$(drupal_site_env "${site}" "SOLR_PORT")

  drush -l "${site_url}" -y config:set search_api.server.default_solr_server backend_config.connector_config.host "${host}"
  drush -l "${site_url}" -y config:set search_api.server.default_solr_server backend_config.connector_config.port "${port}"
}

function configure_matomo_module_local {
  local site="${1}"; shift
  local site_url=$(drupal_site_env "${site}" "SITE_URL")
  local site_id=$(($(site_index "${site}")+1))
  local matomo_url=$(drupal_site_env "${site}" "MATOMO_URL")
  local matomo_http_url="http${matomo_url#https}"

  drush -l "${site_url}" -y config-set matomo.settings site_id "${site_id}"
  drush -l "${site_url}" -y config-set matomo.settings url_http "${matomo_http_url}"
  drush -l "${site_url}" -y config-set matomo.settings url_https "${matomo_url}"
}

function configure_openseadragon_local {
  local site="${1}"; shift
  local site_url=$(drupal_site_env "${site}" "SITE_URL")
  local cantaloupe_url=$(drupal_site_env "${site}" "CANTALOUPE_URL")

  drush -l "${site_url}" -y config-set --input-format=yaml openseadragon.settings iiif_server "${cantaloupe_url}"
  drush -l "${site_url}" -y config-set --input-format=yaml islandora_iiif.settings iiif_server "${cantaloupe_url}"
}

function perform_runtime_config {
  local site="${1}"

  # Ensure that settings which depend on environment variables like service urls are set dynamically on startup.
  configure_islandora_module_local "${site}"
  configure_islandora_default_module_local "${site}"
  configure_openseadragon_local "${site}"

  # Settings like the hash / flystem can be affected by environment variables at runtime.
  update_settings_php "${site}"
}

function main {
  local site="default"
  local site_url=$(drupal_site_env "${site}" "SITE_URL")

  # Records whether or not we are starting from an empty database; this is a proxy for determining if Drupal is
  # already installed or not.  If installed_custom returns 0, then Drupal is already installed.  If >0, Drupal is
  # not installed.

  local db_count=0
  $(installed_local) || db_count=$?

  # Install Composer modules if necessary.
  COMPOSER_MEMORY_LIMIT=-1 composer install

  if [ -z "${db_count}" ] || [ "${db_count}" -lt 1 ] ; then
    printf "\n\nERROR: Drupal is not installed, no pre-existing state found\n\n"
    exit 1
  fi

  # Enter maintenance mode, run any database hooks from updated modules,
  # import the configuration, and perform any runtime configuration affected by
  # environment variables.

  # Go into maintenance mode
  enable_maint_mode ${site_url}

  # Run drush updatedb
  drush -l "${site_url}" -y updatedb

  # If a site already exists, and we are not in the "dev" environment, perform a config import.
  # If a site was newly installed by install_site above, the configuration import has already occurred as a
  # part of the install process.
  #
  # This can't be done in dev, because a local developer's active config may be overwritten by the import.
  # But in promoting from dev to stage, or stage to prod, we will want the config to be overwritten.
  if [ -n "${DRUPAL_INSTANCE}" ] && [ "${DRUPAL_INSTANCE}" != "dev" ] ;
  then
    perform_config_import "${site_url}"
  fi

  # Perform runtime configuration if it is not a dev env.
  if [ -n "${DRUPAL_INSTANCE}" ] && [ "${DRUPAL_INSTANCE}" != "dev" ] ;
  then
    perform_runtime_config "${site}"
  fi

  # Disable maintenance mode
  disable_maint_mode "${site_url}"
}

main
