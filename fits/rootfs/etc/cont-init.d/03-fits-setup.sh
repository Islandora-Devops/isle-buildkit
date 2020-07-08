#!/usr/bin/with-contenv bash
set -e

# Change log files to redirect to stdout/stderr
ln -sf /dev/stdout /opt/tomcat/logs/fits-service.log
chown tomcat:tomcat /opt/tomcat/logs/fits-service.log
