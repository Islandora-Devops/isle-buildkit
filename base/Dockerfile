# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM ${repository}/download:${tag} AS download
FROM alpine:3.13.2 AS cache
FROM alpine:3.13.2

ENV DOWNLOAD_CACHE_DIRECTORY=/opt/downloads

# Install packages and tools required by all downstream images.
RUN --mount=type=cache,id=base-apk,sharing=locked,from=cache,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk add \
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
        util-linux \
    && \
    addgroup -g 2000 jwt && \
    echo '' > /root/.ash_history

ARG TARGETARCH

COPY --from=download /usr/local/bin/*.sh /usr/local/bin

# Install s6
RUN --mount=type=cache,id=base-downloads,sharing=locked,from=download,target=/opt/downloads \
    if [ "${TARGETARCH}" = "arm64" ]; then \
        S6_FILE="s6-overlay-aarch64.tar.gz"; \
        S6_SHA256="84f585a100b610124bb80e441ef2dc2d68ac2c345fd393d75a6293e0951ccfc5"; \
    fi; \
    if [ "${TARGETARCH}" = "amd64" ]; then \
        S6_FILE="s6-overlay-amd64.tar.gz"; \
        S6_SHA256="a7076cf205b331e9f8479bbb09d9df77dbb5cd8f7d12e9b74920902e0c16dd98"; \
    fi; \
    S6_VERSION="2.2.0.3" && \
    S6_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/${S6_FILE}" && \
    download.sh --url "${S6_URL}" --sha256 "${S6_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    tar -xzf "${DOWNLOAD_CACHE_DIRECTORY}/${S6_FILE}" -C /  && \
    echo '' > /root/.ash_history

# Install confd
COPY confd/confd-0.15.0-linux-${TARGETARCH} /usr/local/bin/confd

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
    S6_SERVICES_GRACETIME=30000 \
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
