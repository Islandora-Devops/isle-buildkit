#!/command/with-contenv bash
# shellcheck shell=bash
export JAVA_OPTS="${TOMCAT_JAVA_OPTS}"
CATALINA_OPTS="${TOMCAT_CATALINA_OPTS}"
CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.home=/data/home"
CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.velocity.runtime.log=/dev/stdout"
CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.external.content.allowed=/opt/tomcat/conf/allowed-external-content.txt"
CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.autoversioning.enabled=false"

if [ -z "${FCREPO_ACTIVEMQ_QUEUE:-}" ] && [ -z "${FCREPO_ACTIVEMQ_TOPIC:-}" ]; then
  CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.jms.enabled=false"
else
  CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.jms.baseUrl=http://${HOSTNAME}/fcrepo/rest"
  CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.activemq.directory=file:///data/home/data/Activemq"
  CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.activemq.configuration=file:///opt/tomcat/conf/activemq.xml"
fi

CATALINA_OPTS="${CATALINA_OPTS} -DconnectionTimeout=${FCREPO_CATALINA_TIMEOUT:=-1}"

case "${DB_DRIVER}" in
none)
    # No action required.
    ;;
mysql)
    CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.db.url=jdbc:mysql://${DB_MYSQL_HOST}:${DB_MYSQL_PORT}/${FCREPO_DB_NAME}"
    ;;
postgresql)
    CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.db.url=jdbc:postgresql://${DB_POSTGRESQL_HOST}:${DB_POSTGRESQL_PORT}/${FCREPO_DB_NAME}"
    ;;
*)
    echo "Only mysql/postgresql are supported values for DB_DRIVER." >&2
    exit 1
    ;;
esac

if [[ "${DB_DRIVER}" != "none" ]]; then
    CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.db.user=${FCREPO_DB_USER}"
    CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.db.password=${FCREPO_DB_PASSWORD}"
fi

if [[ "${FCREPO_DISABLE_SYN}" == "true" ]]; then
    CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.properties.management=relaxed"
fi

if [[ "${FCREPO_BINARYSTORAGE_TYPE}" == "file" ]]; then
    CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.storage=ocfl-fs"
fi
if [[ "${FCREPO_BINARYSTORAGE_TYPE}" == "s3" ]]; then
    # Enable S3 mode and set default options
    CATALINA_OPTS="${CATALINA_OPTS} -Dfcrepo.storage=ocfl-s3 -Dfcrepo.aws.region=${FCREPO_AWS_REGION} -Dfcrepo.ocfl.s3.bucket=${FCREPO_S3_BUCKET} -Dfcrepo.ocfl.s3.prefix=${FCREPO_S3_PREFIX}"
fi


export CATALINA_OPTS
