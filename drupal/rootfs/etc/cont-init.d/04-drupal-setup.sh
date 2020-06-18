#!/usr/bin/with-contenv bash
set -e

function create_database {
    local db_name="${1}"; shift
    local db_user="${1}"; shift
    local db_password="${1}"; shift
    /usr/local/bin/create-drupal-database.sh \
        --driver "${DRUPAL_DB_DRIVER}" \
        --host "${DRUPAL_DB_HOST}" \
        --port "${DRUPAL_DB_PORT}" \
        --user "${DRUPAL_DB_ROOT_USER}" \
        --password "${DRUPAL_DB_ROOT_PASSWORD}" \
        --db-name "${db_name}" \
        --db-user "${db_user}" \
        --db-password "${db_password}"
}

function create_default_site_database {
    create_database \
        "${DRUPAL_DEFAULT_DB_NAME}" \
        "${DRUPAL_DEFAULT_DB_USER}" \
        "${DRUPAL_DEFAULT_DB_PASSWORD}"
}

function create_site_database {
    local site="${1}"
    local db_name_var="DRUPAL_SITE_${site}_DB_NAME"
    local db_user_var="DRUPAL_SITE_${site}_DB_USER"
    local db_password_var="DRUPAL_SITE_${site}_DB_PASSWORD"
    create_database \
        "${!db_name_var}" \
        "${!db_user_var}" \
        "${!db_password_var}"
}

function create_subsite_databases {
    for site in ${DRUPAL_SITES}; do
        create_site_database "${site}"
    done
}

function install_site {
    local db_name="${1}"; shift
    local config_dir_arg="${1}"; shift
    # Config directory is optional only works with non-standard profiles.
    # https://www.drupal.org/project/drupal/issues/2982052
    if [[ ! -z "${config_dir_arg}" ]]; then
        config_dir_arg="--config-dir=${config_dir_arg}"
    fi
    /usr/local/bin/install-drupal-site.sh \
        --driver "${DRUPAL_DB_DRIVER}" \
        --host "${DRUPAL_DB_HOST}" \
        --port "${DRUPAL_DB_PORT}" \
        --user "${DRUPAL_DB_ROOT_USER}" \
        --password "${DRUPAL_DB_ROOT_PASSWORD}" \
        --db-name "${db_name}" \
        ${@} ${config_dir_arg}
}

function install_default_site {
    if [ "${DRUPAL_DEFAULT_INSTALL}" = "true" ]; then
        install_site \
            "${DRUPAL_DEFAULT_DB_NAME}" \
            "${DRUPAL_DEFAULT_CONFIGDIR}" \
            "${DRUPAL_DEFAULT_PROFILE}" \
            --sites-subdir="${DRUPAL_DEFAULT_SUBDIR}" \
            --site-name="${DRUPAL_DEFAULT_NAME}" \
            --site-mail="${DRUPAL_DEFAULT_EMAIL}" \
            --locale="${DRUPAL_DEFAULT_LOCALE}" \
            --account-name="${DRUPAL_DEFAULT_ACCOUNT_NAME}" \
            --account-pass="${DRUPAL_DEFAULT_ACCOUNT_PASSWORD}" \
            --account-mail="${DRUPAL_DEFAULT_ACCOUNT_EMAIL}"
    fi
}

function install_subsite {
    local site="${1}"
    local db_name_var="DRUPAL_SITE_${site}_DB_NAME"
    local config_dir_var="DRUPAL_SITE_${site}_CONFIGDIR"
    local profile_var="DRUPAL_SITE_${site}_PROFILE"
    local subdir_var="DRUPAL_SITE_${site}_SUBDIR"
    local site_name_var="DRUPAL_SITE_${site}_NAME"
    local site_email_var="DRUPAL_SITE_${site}_EMAIL"
    local site_locale_var="DRUPAL_SITE_${site}_LOCALE"
    local account_name_var="DRUPAL_SITE_${site}_ACCOUNT_NAME"
    local account_password_var="DRUPAL_SITE_${site}_ACCOUNT_PASSWORD"
    local account_email_var="DRUPAL_SITE_${site}_ACCOUNT_EMAIL"

    install_site \
        "${!db_name_var}" \
        "${!config_dir_var}" \
        "${!profile_var}" \
        --sites-subdir="${!subdir_var}" \
        --site-name="${!site_name_var}" \
        --site-mail="${!site_email_var}" \
        --locale="${!site_locale_var}" \
        --account-name="${!account_name_var}" \
        --account-pass="${!account_password_var}" \
        --account-mail="${!account_email_var}"
}

function install_subsites {
    local install_var=
    for site in ${DRUPAL_SITES}; do
        install_var="DRUPAL_SITE_${site}_INSTALL"
        if [ "${!install_var}" = "true" ]; then
            install_subsite "${site}"
        fi
    done
}

function main {
    create_default_site_database
    install_default_site
    create_subsite_databases
    install_subsites
}
main
