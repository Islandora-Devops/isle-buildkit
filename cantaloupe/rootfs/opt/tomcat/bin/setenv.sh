#!/usr/bin/with-contenv bash
export JAVA_OPTS="${CANTALOUPE_JAVA_OPTS}"
export CATALINA_OPTS="${CANTALOUPE_CATALINA_OPTS}"
export CATALINA_OPTS="${CATALINA_OPTS} -Dcantaloupe.config=/opt/tomcat/conf/cantaloupe.properties"
export CATALINA_OPTS="${CATALINA_OPTS} -Dorg.apache.tomcat.util.buf.UDecoder.ALLOW_ENCODED_SLASH=true"
export CATALINA_OPTS="${CATALINA_OPTS} -Dorg.apache.catalina.connector.CoyoteAdapter.ALLOW_BACKSLASH=true"
