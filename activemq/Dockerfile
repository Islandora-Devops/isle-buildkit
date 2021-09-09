# syntax=docker/dockerfile:experimental
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    ACTIVEMQ_VERSION="5.16.3" && \
    ACTIVEMQ_FILE="apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz" && \
    ACTIVEMQ_URL="https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/${ACTIVEMQ_FILE}" && \
    ACTIVEMQ_FILE_SHA256="1846da2985ec64253ecc41a54f1477731eb4750fe840a9dd9fdfee88e5c94252" && \
    ACTIVEMQ_SIG_SHA256="ba60843a12fd74424d4ec62752e888b0b58fecd53c63f1497f8ea0cb6ef5d457" && \
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
