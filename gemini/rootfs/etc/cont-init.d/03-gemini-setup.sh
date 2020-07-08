#!/usr/bin/with-contenv bash
set -e
/var/run/islandora/create-gemini-database.sh
php bin/console --no-interaction migrations:migrate
