# syntax=docker/dockerfile:1.5.1
FROM java

ARG TARGETARCH
# renovate: datasource=custom.handle depName=handle packageName=handle
ARG HANDLE_VERSION=9.3.2
ARG HANDLE_FILE="handle-${HANDLE_VERSION}-distribution.tar.gz"
ARG HANDLE_URL="https://handle.net/hnr-source/${HANDLE_FILE}"
ARG HANDLE_FILE_SHA256="b3d03ef44740e34c0adfef4356f1308bb7886aaba6b22e7e019138d9850eb29e"

# renovate: datasource=github-tags depName=jdbc-mysql packageName=mysql/mysql-connector-j
ARG MYSQL_DRIVER_VERSION=9.4.0
ARG MYSQL_DRIVER_FILE="mysql-connector-j-${MYSQL_DRIVER_VERSION}.tar.gz"
ARG MYSQL_DRIVER_URL="https://dev.mysql.com/get/Downloads/Connector-J/${MYSQL_DRIVER_FILE}"
ARG MYSQL_DRIVER_FILE_SHA256="83d76179dc59d4aa0035ad2f7ef8c6a0e8c43a169dd0c2bf808feb6ed83fe4f2"

# renovate: datasource=github-releases depName=jdbc-postgres packageName=pgjdbc/pgjdbc
ARG POSTGRES_DRIVER_VERSION=42.7.7
ARG POSTGRES_DRIVER_FILE="postgresql-${POSTGRES_DRIVER_VERSION}.jar"
ARG POSTGRES_DRIVER_URL="https://jdbc.postgresql.org/download/${POSTGRES_DRIVER_FILE}"
ARG POSTGRES_DRIVER_FILE_SHA256="157963d60ae66d607e09466e8c0cdf8087e9cb20d0159899ffca96bca2528460"

EXPOSE 8000/tcp 2641/tcp 2641/udp

WORKDIR /var/handle

# Download Handle & the java mysql driver
# And install them into /opt/handle directory
#
# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=handle-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${HANDLE_URL}" \
        --sha256 "${HANDLE_FILE_SHA256}" \
        --strip \
        --dest "/opt/handle" \
        doc \
        handle-9.3.0-src.zip \
        jeUpgradeTool \
    && \
    download.sh \
        --url "${MYSQL_DRIVER_URL}" \
        --sha256 "${MYSQL_DRIVER_FILE_SHA256}" \
        --strip \
        --dest "/tmp/mysql-connector-java" \
    && \
    mv "/tmp/mysql-connector-java/${MYSQL_DRIVER_FILE%%.tar.gz}.jar" /opt/handle/lib && \
    download.sh \
        --url "${POSTGRES_DRIVER_URL}" \
        --sha256 "${POSTGRES_DRIVER_FILE_SHA256}" \
        --dest "/opt/handle/lib" \
    && \
    cleanup.sh

RUN create-service-user.sh --name handle /opt/keys/handle /var/handle /var/handle/logs && \
    cleanup.sh

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

COPY --link rootfs /
