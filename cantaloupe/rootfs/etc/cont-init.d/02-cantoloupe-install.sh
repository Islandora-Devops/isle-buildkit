#!/usr/bin/env bash
set -e

# Change log files to redirect to stdout/stderr
ln -sf /dev/stdout /opt/tomcat/logs/cantaloupe.access.log
chown tomcat:tomcat /opt/tomcat/logs/cantaloupe.access.log

ln -sf /dev/stderr /opt/tomcat/logs/cantaloupe.error.log
chown tomcat:tomcat /opt/tomcat/logs/cantaloupe.error.log
