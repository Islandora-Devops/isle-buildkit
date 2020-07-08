#!/usr/bin/with-contenv bash
set -e
/var/run/islandora/create-matomo-database.sh
/var/run/islandora/update-matomo-database.sh
