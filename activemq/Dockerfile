# syntax=docker/dockerfile:1.5.1
FROM java

ARG TARGETARCH
# renovate: datasource=github-tags depName=apache-activemq packageName=apache/activemq
ARG ACTIVEMQ_VERSION=5.19.0
ARG ACTIVEMQ_FILE="apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz"
ARG ACTIVEMQ_URL="https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/${ACTIVEMQ_FILE}"
ARG ACTIVEMQ_FILE_SHA256="5ed946596ff8e93d0001219bef1cc379e09c1dc5bb49f11981dae6c0674d223d"

EXPOSE 61616 5672 61613 1883 61614 8161

WORKDIR /opt/activemq

RUN --mount=type=cache,id=activemq-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${ACTIVEMQ_URL}" \
        --sha256 "${ACTIVEMQ_FILE_SHA256}" \
        --dest /opt/activemq \
        --strip \
        examples webapps-demo docs \
    && \
    cleanup.sh

# Defaults environment variables to be overloaded.
ENV \
    ACTIVEMQ_AUDIT_LOG_LEVEL=INFO \
    ACTIVEMQ_LOG_LEVEL=INFO \
    ACTIVEMQ_PASSWORD=password \
    ACTIVEMQ_USER=admin \
    ACTIVEMQ_WEB_ADMIN_NAME=admin \
    ACTIVEMQ_WEB_ADMIN_PASSWORD=password \
    ACTIVEMQ_WEB_ADMIN_ROLES=admin

COPY --link rootfs /

RUN create-service-user.sh --name activemq && \
    cleanup.sh

HEALTHCHECK CMD curl -s \
    -u admin:"$(cat /var/run/s6/container_environment/ACTIVEMQ_WEB_ADMIN_PASSWORD)" \
    -H origin:localhost \
    "http://localhost:8161/api/jolokia/read/org.apache.activemq:type=Broker,brokerName=localhost,service=Health/CurrentStatus" \
    | jq .value | grep -q Good
