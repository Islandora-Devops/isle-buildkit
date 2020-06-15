#!/usr/bin/with-contenv bash
set -e
# Key needs to be present before startup otherwise,
# it will ignore subsequent requests even if the key has been generated.
timeout 300 bash -c 'until [[ -f /opt/keys/jwt/public.key ]]; do sleep 1; done'

# Change log files to redirect to stdout/stderr
ln -sf /dev/stdout /opt/tomcat/logs/velocity.log
chown tomcat:tomcat /opt/tomcat/logs/velocity.log
