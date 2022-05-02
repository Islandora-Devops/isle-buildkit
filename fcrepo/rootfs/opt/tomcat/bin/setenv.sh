#!/usr/bin/with-contenv bash
export JAVA_OPTS="${TOMCAT_JAVA_OPTS}"
export CATALINA_OPTS="${TOMCAT_CATALINA_OPTS}"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.home=/data/home"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.velocity.runtime.log=/dev/stdout"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.modeshape.configuration=${FCREPO_MODESHAPE_CONFIGURATION} -Dfcrepo.jms.baseUrl=http://${HOSTNAME}/fcrepo/rest"
if [[ "${FCREPO_DISABLE_SYN}" == "true" ]]; then
  export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.properties.management=relaxed"
fi
