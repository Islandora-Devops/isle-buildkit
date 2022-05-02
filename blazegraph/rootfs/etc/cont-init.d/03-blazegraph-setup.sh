#!/usr/bin/with-contenv bash
set -e

# When bind mounting we need to ensure that we
# actually can write to the folder.
chown tomcat:tomcat /data
