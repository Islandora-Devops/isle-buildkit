# syntax=docker/dockerfile:experimental
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    ACTIVEMQ_VERSION="5.14.5" && \
    ACTIVEMQ_FILE="apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz" && \
    ACTIVEMQ_URL="https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/${ACTIVEMQ_FILE}" && \
    ACTIVEMQ_FILE_SHA256="a4bc310ccb3fb439d0ba159e43f0e08e8073caf050c95e5e07c1a6d5f3f9a86e" && \
    ACTIVEMQ_SIG_SHA256="3bab7224602e7b2c3b660352a2e329b0ac18359aa265163438e573ff32e06c1d" && \
    download.sh --url "${ACTIVEMQ_URL}" --sha256 "${ACTIVEMQ_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh --url "${ACTIVEMQ_URL}.asc" --sha256 "${ACTIVEMQ_SIG_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name activemq \
        --key "62ED4DF0BACB8793" \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${ACTIVEMQ_FILE}" \
        examples webapps-demo docs

WORKDIR /opt/activemq

EXPOSE 61616 5672 61613 1883 61614 8161

VOLUME [ "/opt/activemq/data" ]

COPY rootfs /
