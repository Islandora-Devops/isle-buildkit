# syntax=docker/dockerfile:experimental
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    TOMCAT_VERSION="9.0.59" && \
    TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
    TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE}" && \
    TOMCAT_FILE_SHA256="22e3ced754b22ab6719d3c4387f24f48c47c9de051e377bfb54d23a712f1c42d" && \
    TOMCAT_SIG_SHA256="3bf1cb00fe97ea6c0703367034e84c9959f668baf7eb77806ac24332a8a6644a" && \
    download.sh --url "${TOMCAT_URL}" --sha256 "${TOMCAT_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh --url "${TOMCAT_URL}.asc" --sha256 "${TOMCAT_SIG_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name tomcat \
        --key "A9C5DF4D22E99998D9875A5110C01C5A2F6059E7" \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${TOMCAT_FILE}" \ 
        webapps/docs webapps/examples

# Install reverse proxy to redirect from 80 to 8080.
RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \ 
    apk-install.sh nginx && \
    cleanup.sh

WORKDIR /opt/tomcat

EXPOSE 8080

COPY rootfs /
