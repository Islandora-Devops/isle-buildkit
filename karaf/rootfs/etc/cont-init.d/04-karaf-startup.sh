#!/usr/bin/with-contenv bash
set -e
# On startup if we exit with sigterm the pid file is left behind sometimes.
rm /opt/karaf/instances/instance.properties &> /dev/null || true