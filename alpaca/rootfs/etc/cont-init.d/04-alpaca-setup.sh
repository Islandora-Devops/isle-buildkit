#!/usr/bin/with-contenv bash
set -e

# Change log files to redirect to stdout/stderr
ln -sf /dev/stdout /opt/karaf/data/log/camel.log
chown karaf:karaf /opt/karaf/data/log/camel.log

ln -sf /dev/stdout /opt/karaf/data/log/islandora.log
chown karaf:karaf /opt/karaf/data/log/islandora.log
