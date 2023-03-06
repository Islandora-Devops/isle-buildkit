# syntax=docker/dockerfile:1.5.1
FROM java

ARG TARGETARCH
ARG HANDLE_VERSION="9.3.0"
ARG HANDLE_FILE="handle-${HANDLE_VERSION}-distribution.tar.gz"
ARG HANDLE_URL="http://handle.net/hnr-source/${HANDLE_FILE}"
ARG HANDLE_FILE_SHA256="7bbf155842b098df9eb3e6e24778be23bc74365cf0f2b1b2acb0ae111a54bdaf"

ARG MYSQL_DRIVER_VERSION="8.0.31"
ARG MYSQL_DRIVER_FILE="mysql-connector-j-${MYSQL_DRIVER_VERSION}.tar.gz"
ARG MYSQL_DRIVER_URL="https://dev.mysql.com/get/Downloads/Connector-J/${MYSQL_DRIVER_FILE}"
ARG MYSQL_DRIVER_FILE_SHA256="03e3908f070bfe216f0458c8c4de0b3e47ed3182b37d39bcd2082dbd767d5f91"

ARG POSTGRES_DRIVER_VERSION="42.5.1"
ARG POSTGRES_DRIVER_FILE="postgresql-${POSTGRES_DRIVER_VERSION}.jar"
ARG POSTGRES_DRIVER_URL="https://jdbc.postgresql.org/download/${POSTGRES_DRIVER_FILE}"
ARG POSTGRES_DRIVER_FILE_SHA256="89e8bffa8b37b9487946012c690cf04f3103953051c1c193d88ee36b68d365ae"

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
