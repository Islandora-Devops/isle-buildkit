#!/usr/bin/with-contenv bash
set -e

# Change log files to redirect to stdout/stderr
ln -sf /dev/stdout /opt/tomcat/logs/rules.log
chown tomcat:tomcat /opt/tomcat/logs/rules.log

ln -sf /dev/stdout /opt/tomcat/logs/queryLog.csv
chown tomcat:tomcat /dev/stdout /opt/tomcat/logs/queryLog.csv

ln -sf /dev/stdout /opt/tomcat/logs/queryRunState.log
chown tomcat:tomcat /dev/stdout /opt/tomcat/logs/queryRunState.log

ln -sf /dev/stdout /opt/tomcat/logs/solutions.csv
chown tomcat:tomcat /dev/stdout /opt/tomcat/logs/solutions.csv

ln -sf /dev/stdout /opt/tomcat/logs/sparql.txt
chown tomcat:tomcat /dev/stdout /opt/tomcat/logs/sparql.txt

# When bind mounting we need to ensure that we
# actually can write to the folder.
chown tomcat:tomcat /data
