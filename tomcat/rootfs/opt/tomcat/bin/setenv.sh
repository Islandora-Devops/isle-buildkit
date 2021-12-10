#!/usr/bin/with-contenv bash
export JAVA_OPTS="${TOMCAT_JAVA_OPTS} ‐Dlog4j2.formatMsgNoLookups=True"
export CATALINA_OPTS="${TOMCAT_CATALINA_OPTS}"
