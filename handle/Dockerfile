# syntax=docker/dockerfile:experimental
# Visit https://github.com/Islandora-Devops/isle-buildkit for info about the container used
FROM local/java:latest

# Download Handle & the java mysql driver
# And install them into /opt/handle directory
RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    HANDLE_VERSION="9.3.0" && \
    HANDLE_FILE="handle-${HANDLE_VERSION}-distribution.tar.gz" && \
    HANDLE_URL="http://handle.net/hnr-source/${HANDLE_FILE}" && \
    HANDLE_FILE_SHA256="7bbf155842b098df9eb3e6e24778be23bc74365cf0f2b1b2acb0ae111a54bdaf" && \
    download.sh --url "${HANDLE_URL}" --sha256 "${HANDLE_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    MYSQL_DRIVER_VERSION=8.0.22 && \
    MYSQL_DRIVER_FILE="mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz" && \
    MYSQL_DRIVER_URL="https://dev.mysql.com/get/Downloads/Connector-J/${MYSQL_DRIVER_FILE}" && \
    MYSQL_DRIVER_FILE_SHA256="10e4bbe3269a26a6ee95b6ad8746632b3a4c59cb99320f52b65f455d60db7a62" && \
    download.sh --url "${MYSQL_DRIVER_URL}" --sha256 "${MYSQL_DRIVER_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    POSTGRES_DRIVER_VERSION=42.2.18 && \
    POSTGRES_DRIVER_FILE="postgresql-${POSTGRES_DRIVER_VERSION}.jar" && \
    POSTGRES_DRIVER_URL="https://jdbc.postgresql.org/download/${POSTGRES_DRIVER_FILE}" && \
    POSTGRES_DRIVER_FILE_SHA256="0c891979f1eb2fe44432da114d09760b5063dad9e669ac0ac6b0b6bfb91bb3ba" && \
    download.sh --url "${POSTGRES_DRIVER_URL}" --sha256 "${POSTGRES_DRIVER_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-service.sh --name "handle" --file "${DOWNLOAD_CACHE_DIRECTORY}/${HANDLE_FILE}" doc handle-9.3.0-src.zip jeUpgradeTool && \
    tar -xzf "${DOWNLOAD_CACHE_DIRECTORY}/${MYSQL_DRIVER_FILE}" -C /opt/handle/lib "mysql-connector-java-${MYSQL_DRIVER_VERSION}/${MYSQL_DRIVER_FILE%%.tar.gz}.jar" --strip-components 1 && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${POSTGRES_DRIVER_FILE}" "/opt/handle/lib/${POSTGRES_DRIVER_FILE}" && \
    mkdir -p /opt/handle /opt/keys/handle /var/handle/logs && \
    chown -R handle:handle /opt/handle /opt/keys/handle /var/handle && \
    cleanup.sh

WORKDIR /var/handle

EXPOSE 8000/tcp
EXPOSE 2641/tcp
EXPOSE 2641/udp

COPY rootfs /
