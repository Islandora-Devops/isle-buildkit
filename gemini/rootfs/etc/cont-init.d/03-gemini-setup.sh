#!/usr/bin/with-contenv bash
set -e
/var/run/islandora/create-gemini-database.sh
php bin/console --no-interaction migrations:migrate

# Change log files to redirect to stdout/stderr
ln -sf /dev/stdout /var/log/islandora/gemini.log
chown nginx:nginx /var/log/islandora/gemini.log
