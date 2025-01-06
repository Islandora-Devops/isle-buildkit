# syntax=docker/dockerfile:1.5.1
FROM java

ARG TARGETARCH
ARG HANDLE_VERSION=9.3.1
ARG HANDLE_FILE="handle-${HANDLE_VERSION}-distribution.tar.gz"
ARG HANDLE_URL="https://handle.net/hnr-source/${HANDLE_FILE}"
ARG HANDLE_FILE_SHA256="03c659511acb0f11a89d7f8993f47b156c3b93b288ef64a3170e09a32c526417"

# renovate: datasource=github-tags depName=jdbc-mysql packageName=mysql/mysql-connector-j
ARG MYSQL_DRIVER_VERSION=9.1.0
ARG MYSQL_DRIVER_FILE="mysql-connector-j-${MYSQL_DRIVER_VERSION}.tar.gz"
ARG MYSQL_DRIVER_URL="https://dev.mysql.com/get/Downloads/Connector-J/${MYSQL_DRIVER_FILE}"
ARG MYSQL_DRIVER_FILE_SHA256="f5198db93f529206d7f13f613c38753fec0b698be9f5410391aed1d62c57acb7"

# renovate: datasource=github-releases depName=jdbc-postgres packageName=pgjdbc/pgjdbc
ARG POSTGRES_DRIVER_VERSION=42.7.4
ARG POSTGRES_DRIVER_FILE="postgresql-${POSTGRES_DRIVER_VERSION}.jar"
ARG POSTGRES_DRIVER_URL="https://jdbc.postgresql.org/download/${POSTGRES_DRIVER_FILE}"
ARG POSTGRES_DRIVER_FILE_SHA256="188976721ead8e8627eb6d8389d500dccc0c9bebd885268a3047180274a6031e"

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
