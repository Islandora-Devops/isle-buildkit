# syntax=docker/dockerfile:1.2.1
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    KARAF_VERSION="4.0.8" && \
    KARAF_FILE="apache-karaf-${KARAF_VERSION}.tar.gz" && \
    KARAF_URL="https://archive.apache.org/dist/karaf/${KARAF_VERSION}/${KARAF_FILE}" && \
    KARAF_FILE_SHA256="67e555e3896fbe87d23ceec008898bb33133f36b48d7e5ede363c214a54e7d2a" && \
    KARAF_SIG_SHA256="bba601fdcef14e0ac970244c27c2e8af91c58f5f9fbbab1d1b05293f331dbaf4" && \
    download.sh --url "${KARAF_URL}" --sha256 "${KARAF_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh --url "${KARAF_URL}.asc" --sha256 "${KARAF_SIG_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name karaf \
        --key "BFF2EE42C8282E76" \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${KARAF_FILE}" \ 
        demos \
    && \
    sed -i 's@http://repo1@https://repo1@' /opt/karaf/etc/org.ops4j.pax.url.mvn.cfg && \
    mkdir /opt/karaf/data/log && \
    chown -R karaf:karaf /opt/karaf && \
    rm -rf /opt/karaf/instances/* && \
    cleanup.sh

WORKDIR /opt/karaf

EXPOSE 8101 1099 44444 8181

ENV \
    KARAF_ADMIN_NAME=admin \
    KARAF_ADMIN_PASSWORD=password

COPY rootfs /
