# syntax=docker/dockerfile:experimental
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    TOMCAT_VERSION="9.0.41" && \
    TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
    TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE}" && \
    TOMCAT_FILE_SHA256="6a5fc1f79f002f25480e3a50daa1fb16fdb2f0a969bc2f806c88bc550002cf71" && \
    TOMCAT_SIG_SHA256="2bf8fe2b4a993b799a8ea6018bda46f05a00ba9931bf904c97b3e912e30d0b69" && \
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
