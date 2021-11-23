# syntax=docker/dockerfile:experimental
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    TOMCAT_VERSION="9.0.55" && \
    TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
    TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE}" && \
    TOMCAT_FILE_SHA256="63e37ced106daf9b7d1516d1d4e230593c7ff2e1021effe91bc552a751469181" && \
    TOMCAT_SIG_SHA256="1b9969648b2848822443f594187bfe45594944eef20c28ea3c49d7f0d6c18dfe" && \
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
