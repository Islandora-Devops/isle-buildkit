# syntax=docker/dockerfile:experimental
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    ACTIVEMQ_VERSION="5.16.1" && \
    ACTIVEMQ_FILE="apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz" && \
    ACTIVEMQ_URL="https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/${ACTIVEMQ_FILE}" && \
    ACTIVEMQ_FILE_SHA256="43d3f3a890bffae85c6f1002e9cf950fcc1fd17f3f5e55dc3b85d39d09e2e323" && \
    ACTIVEMQ_SIG_SHA256="e3c88ec044bc50a30da64f2beb7b7b937ca8bcdcba82d06df94e3e04ec9893c1" && \
    download.sh --url "${ACTIVEMQ_URL}" --sha256 "${ACTIVEMQ_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh --url "${ACTIVEMQ_URL}.asc" --sha256 "${ACTIVEMQ_SIG_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name activemq \
        --key "1AA8CF92D409A73393D0B736BFF2EE42C8282E76" \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${ACTIVEMQ_FILE}" \
        examples webapps-demo docs

WORKDIR /opt/activemq

EXPOSE 61616 5672 61613 1883 61614 8161

COPY rootfs /
