# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

ARG HANDLE_VERSION="9.3.0"
ARG HANDLE_FILE_SHA256="7bbf155842b098df9eb3e6e24778be23bc74365cf0f2b1b2acb0ae111a54bdaf"
ARG MYSQL_DRIVER_VERSION="8.0.22"
ARG MYSQL_DRIVER_FILE_SHA256="10e4bbe3269a26a6ee95b6ad8746632b3a4c59cb99320f52b65f455d60db7a62"
ARG POSTGRES_DRIVER_VERSION="42.2.18"
ARG POSTGRES_DRIVER_FILE_SHA256="0c891979f1eb2fe44432da114d09760b5063dad9e669ac0ac6b0b6bfb91bb3ba"

# Download Handle & the java mysql driver
# And install them into /opt/handle directory
RUN --mount=type=cache,id=handle-downloads,sharing=locked,target=/opt/downloads \
    HANDLE_FILE="handle-${HANDLE_VERSION}-distribution.tar.gz" && \
    HANDLE_URL="http://handle.net/hnr-source/${HANDLE_FILE}" && \
    download.sh --url "${HANDLE_URL}" --sha256 "${HANDLE_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    MYSQL_DRIVER_FILE="mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz" && \
    MYSQL_DRIVER_URL="https://dev.mysql.com/get/Downloads/Connector-J/${MYSQL_DRIVER_FILE}" && \
    download.sh --url "${MYSQL_DRIVER_URL}" --sha256 "${MYSQL_DRIVER_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    POSTGRES_DRIVER_FILE="postgresql-${POSTGRES_DRIVER_VERSION}.jar" && \
    POSTGRES_DRIVER_URL="https://jdbc.postgresql.org/download/${POSTGRES_DRIVER_FILE}" && \
    download.sh --url "${POSTGRES_DRIVER_URL}" --sha256 "${POSTGRES_DRIVER_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-service.sh --name "handle" --file "${DOWNLOAD_CACHE_DIRECTORY}/${HANDLE_FILE}" doc handle-9.3.0-src.zip jeUpgradeTool && \
    tar -xzf "${DOWNLOAD_CACHE_DIRECTORY}/${MYSQL_DRIVER_FILE}" -C /opt/handle/lib "mysql-connector-java-${MYSQL_DRIVER_VERSION}/${MYSQL_DRIVER_FILE%%.tar.gz}.jar" --strip-components 1 && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${POSTGRES_DRIVER_FILE}" "/opt/handle/lib/${POSTGRES_DRIVER_FILE}" && \
    mkdir -p \
        /opt/keys/handle \
        /var/handle/logs \
    && \
    chown -R handle:handle \
        /opt/handle \
        /opt/keys/handle \
        /var/handle

FROM ${repository}/java:${tag}

EXPOSE 8000/tcp
EXPOSE 2641/tcp
EXPOSE 2641/udp

# The following are defined in /etc/defaults:
# - HANDLE_ADMIN_PRIVATE_KEY_PEM
# - HANDLE_ADMIN_PUBLIC_KEY_PEM
# - HANDLE_PRIVATE_KEY_PEM
# - HANDLE_PUBLIC_KEY_PEM
# As Docker does not support setting multiline environment variables via ENV.
ENV \
    HANDLE_ADMIN_FULL_ACCESS=yes \
    HANDLE_ALLOW_NA_ADMINS=yes \
    HANDLE_CASE_SENSITIVE=no \
    HANDLE_DB_NAME=handle \
    HANDLE_DB_PASSWORD=password \
    HANDLE_DB_READONLY=no \
    HANDLE_DB_USER=handle \
    HANDLE_MAX_AUTH_TIME=60000 \
    HANDLE_MAX_SESSION_TIME=86400000 \
    HANDLE_PREFIX=200 \
    HANDLE_SERVER_ID=1 \
    HANDLE_PERSISTENCE_TYPE=bdbje \
    HANDLE_TEMPLATE_NS_OVERRIDE=no

WORKDIR /var/handle

COPY --link --from=download /etc/group /etc/group
COPY --link --from=download /etc/passwd /etc/passwd
COPY --link --from=download /etc/shadow /etc/shadow
COPY --link --from=download /opt/handle /opt/handle
COPY --link --from=download /opt/keys/handle /opt/keys/handle
COPY --link --from=download /var/handle /var/handle

COPY --link rootfs /

RUN chown -R handle:handle /opt/handle /opt/keys/handle /var/handle
