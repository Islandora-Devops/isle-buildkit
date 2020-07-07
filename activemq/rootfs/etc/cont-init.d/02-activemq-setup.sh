#!/usr/bin/with-contenv bash
set -e

# Change log files to redirect to stdout/stderr
ln -sf /dev/stdout /opt/activemq/data/activemq.log
chown activemq:activemq /opt/activemq/data/activemq.log

ln -sf /dev/stdout /opt/activemq/data/audit.log
chown activemq:activemq /opt/activemq/data/audit.log

# When bind mounting we need to ensure that we
# actually can write to the folder.
chown activemq:activemq /opt/activemq/data
