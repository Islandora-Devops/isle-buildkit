# syntax=docker/dockerfile:1.5.1
FROM java

ARG TARGETARCH
# renovate: datasource=github-tags depName=apache-activemq packageName=apache/activemq
ARG ACTIVEMQ_VERSION=5.18.5
ARG ACTIVEMQ_FILE="apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz"
ARG ACTIVEMQ_URL="https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/${ACTIVEMQ_FILE}"
ARG ACTIVEMQ_FILE_SHA256="1190b809a35ceb5fb0273f4a47d4584684d75c43360942be10d9af1fc0a39394"

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
