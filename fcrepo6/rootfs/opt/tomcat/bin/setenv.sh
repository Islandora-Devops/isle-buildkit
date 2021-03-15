#!/bin/sh
export JAVA_OPTS="${FCREPO_JAVA_OPTS}"
export CATALINA_OPTS="${FCREPO_CATALINA_OPTS}"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.home=/data/home"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.velocity.runtime.log=/opt/tomcat/logs/velocity.log"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.jms.baseUrl=http://${HOSTNAME}/fcrepo/rest"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.external.content.allowed=/opt/tomcat/conf/allowed-external-content.txt"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.autoversioning.enabled=false"
if [[ "${FCREPO_PERSISTENCE_TYPE}" == "mysql" ]] || [[ "${FCREPO_PERSISTENCE_TYPE}" == "mariadb" ]]; then
    export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.db.url=jdbc:${FCREPO_PERSISTENCE_TYPE}://${FCREPO_DB_MYSQL_HOST}:${FCREPO_DB_MYSQL_PORT}/fcrepo"
else
    export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.db.url=jdbc:${FCREPO_PERSISTENCE_TYPE}://${FCREPO_DB_POSTGRESQL_HOST}:${FCREPO_DB_POSTGRESQL_PORT}/fcrepo"
fi
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.db.user=${FCREPO_DB_USER}"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.db.password=${FCREPO_DB_PASSWORD}"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.activemq.directory=file:///data/home/data/Activemq"
export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.activemq.configuration=file:///opt/tomcat/conf/activemq.xml"
if [[ "${FCREPO_DISABLE_SYN}" == "true" ]]; then
  export CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.properties.management=relaxed"
fi
