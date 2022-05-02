#!/usr/bin/with-contenv bash
set -e

# When bind mounting we need to ensure that we
# actually can write to the folder.
chown activemq:activemq /opt/activemq/data
