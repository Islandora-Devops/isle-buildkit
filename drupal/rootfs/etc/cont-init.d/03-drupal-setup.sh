#!/usr/bin/with-contenv bash
set -e
/var/run/islandora/create-drupal-databases.sh
/var/run/islandora/drupal-install-sites.sh
