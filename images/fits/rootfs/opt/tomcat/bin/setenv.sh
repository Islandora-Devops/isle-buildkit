#!/command/with-contenv bash
# shellcheck shell=bash
export JAVA_OPTS="${TOMCAT_JAVA_OPTS}"
export CATALINA_OPTS="${TOMCAT_CATALINA_OPTS}"
export CATALINA_OPTS="${CATALINA_OPTS} -Djna.boot.library.path=/usr/lib"
export CATALINA_OPTS="${CATALINA_OPTS} -Djna.nosys=false"
