#!/usr/bin/with-contenv bash
set -e
# On startup if we exit with sigterm the pid file is left behind sometimes.
rm /opt/karaf/instances/instance.properties &> /dev/null || true

# Change log files to redirect to stdout/stderr
ln -sf /dev/stdout /opt/karaf/data/log/karaf.log
chown karaf:karaf /opt/karaf/data/log/karaf.log
