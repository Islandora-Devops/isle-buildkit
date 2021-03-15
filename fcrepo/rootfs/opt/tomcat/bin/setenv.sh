#!/usr/bin/with-contenv bash
export JAVA_OPTS="${CANTALOUPE_JAVA_OPTS}"
export CATALINA_OPTS="${CANTALOUPE_CATALINA_OPTS}"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.home=/data/home"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.velocity.runtime.log=/opt/tomcat/logs/velocity.log"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.modeshape.configuration=${FCREPO_MODESHAPE_CONFIGURATION} -Dfcrepo.jms.baseUrl=http://${HOSTNAME}/fcrepo/rest"
if [[ "${FCREPO_DISABLE_SYN}" == "true" ]]; then
  export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.properties.management=relaxed"
fi
