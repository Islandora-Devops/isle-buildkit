#!/usr/bin/with-contenv bash
set -e

# Does not run in the context of a login shell so we must explicitly include utilities.sh
source /etc/islandora/utilities.sh

function main {
    local modules=(
        admin_toolbar
        basic_auth
        content_browser
        controlled_access_terms_defaults
        devel
        facets
        islandora_breadcrumbs
        islandora_defaults
        islandora_fits
        islandora_iiif
        islandora_oaipmh
        islandora_search
        matomo
        pdf
        rdf
        responsive_image
        rest
        restui
        search_api_solr
        search_api_solr_defaults
        serialization
        simpletest
        syslog
        transliterate_filenames
    )
    local features=(
        islandora_core_feature
        controlled_access_terms_defaults
        islandora_defaults
        islandora_search
    )

    # We do all sites in a stepwise fashion as it turns out to be faster than
    # configuring one site completely at a time as they get blocked waiting on
    # other services like Fedora to start.
    for_all_sites create_database
    for_all_sites install_site
    for_all_sites update_settings_php

    # Uses the same public/private key for all sub-sites.
    # Required if they share the same backend microservices, etc.
    for_all_sites configure_jwt_module

    # Enable islandora before all other modules so services that require direct
    # communication like ActiveMQ etc have the appropriate settings.
    for_all_sites configure_islandora_module

    # The following commands require several services
    # to be up and running before they can complete.
    for_all_sites wait_for_required_services

    # Create namespace assumed one per site.
    for_all_sites create_blazegraph_namespace_with_default_properties

    # Theme must be enabled before importing features.
    for_all_sites set_carapace_default_theme

    # All subsites are assumed to use the same modules and features.
    for_all_sites enable_modules ${modules[@]}
    for_all_sites import_features ${features[@]}

    # Features overrides some settings for services, so we need to explicitly
    # set them again.
    for_all_sites configure_islandora_module
    for_all_sites configure_matomo_module
    for_all_sites configure_search_api_solr_module
    for_all_sites configure_openseadragon
    for_all_sites configure_islandora_default_module

    # Export configuration now that features have been imported.
    for_all_sites create_solr_core_with_default_config

    # Run migrations.
    for_all_sites import_islandora_migrations

    s6-setuidgid nginx mkdir -p /var/www/drupal/web/simpletest /var/www/drupal/web/sites/simpletest
    s6-setuidgid nginx mkdir -p config/sync

    for_all_sites cache_rebuild
}
main
