#!/usr/bin/with-contenv bash
set -e

# Change log files to redirect to stdout/stderr
ln -sf /dev/stdout /var/log/islandora/milliner.log
chown nginx:nginx /var/log/islandora/milliner.log
