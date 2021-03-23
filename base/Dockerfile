# syntax=docker/dockerfile:1.2.1
FROM alpine:3.11.6

COPY build/ /usr/local/bin/

# Install packages and tools required by all downstream images.
RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \
    --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk add --update \
        bash \
        curl \
        git \
        gnupg \
        mariadb-client \
        mysql-client \
        netcat-openbsd \
        openssl \
        postgresql-client \
        wget \
    && \
    addgroup -g 2000 jwt && \
    S6_VERSION="1.22.1.0" && \
    S6_FILE="s6-overlay-amd64.tar.gz" && \
    S6_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/${S6_FILE}" && \
    S6_SHA256="73f9779203310ddf9c5132546a1978e1a2b05990263b92ed2c34c1e258e2df6c" && \
    S6_SIG_SHA256="7e9c33f45bca1f89b3a1702175a4109e99c911e47ae9de62fbec013406db2b01" && \
    download.sh --url "${S6_URL}" --sha256 "${S6_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh --url "${S6_URL}.sig" --sha256 "${S6_SIG_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    gpg-receive-keys.sh --key 2536CA16DF4FCDA2 && \
    gpg "${DOWNLOAD_CACHE_DIRECTORY}/${S6_FILE}.sig" && \
    tar -xzf "${DOWNLOAD_CACHE_DIRECTORY}/${S6_FILE}" -C / && \
    CONFD_VERSION="0.15.0" && \
    CONFD_URL="https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64" && \
    CONFD_SHA256="7f3aba1d803543dd1df3944d014f055112cf8dadf0a583c76dd5f46578ebe3c2" && \
    download.sh --url "${CONFD_URL}" --sha256 "${CONFD_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/confd-${CONFD_VERSION}-linux-amd64" /usr/local/bin/confd && \
    chmod a+x /usr/local/bin/confd && \
    echo '' > /root/.ash_history

# Start s6
ENTRYPOINT [ "/init" ]

LABEL License="MIT License"

ENV \
    CONFD_BACKEND=env \
    CONFD_ENABLE_SERVICE=false \
    CONFD_LOG_LEVEL=error \
    CONFD_POLLING_INTERVAL=30 \
    ETCD_CONNECTION_TIMEOUT=10 \
    ETCD_PORT=2379 \
    ETCD_HOST=etcd \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICE=1 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=30000 \
    S6_LOGGING=0 \
    TERM=xterm

# JWT_PUBLIC_KEY and JWT_PRIVATE_KEY are defined in /etc/defaults
# As Docker does not support setting multiline environment variables via ENV.
# The 'DB' environment variables can be overridden by prefixing it with the image
# name i.e. `FCREPO_DB_NAME` would override the value for `DB_NAME`.
ENV \ 
    DB_DRIVER=mysql \
    DB_HOST= \
    DB_MYSQL_HOST=mariadb \
    DB_MYSQL_PORT=3306 \
    DB_NAME=default \
    DB_PASSWORD=password \
    DB_PORT= \
    DB_POSTGRESQL_HOST=postgresql \
    DB_POSTGRESQL_PORT=5432 \
    DB_ROOT_PASSWORD=password \
    DB_ROOT_USER=root \
    DB_USER=default \
    JWT_ADMIN_TOKEN=islandora

COPY rootfs /
