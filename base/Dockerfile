# syntax=docker/dockerfile:1.2.1
FROM alpine:3.13.2 AS cache
FROM alpine:3.13.2

COPY build/ /usr/local/bin/

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
    && \
    echo '' > /root/.ash_history

ARG TARGETARCH

# Install s6
RUN --mount=type=cache,id=base-downloads,sharing=locked,target=/opt/downloads \
    if [ "${TARGETARCH}" = "arm64" ]; then \
        S6_FILE="s6-overlay-aarch64.tar.gz"; \
        S6_SHA256="84f585a100b610124bb80e441ef2dc2d68ac2c345fd393d75a6293e0951ccfc5"; \
        S6_SIG_SHA256="90b241a1a8e525c431fefcbbb0bbf90c5cc57b5496d718c441ac56265ede4817"; \
    fi; \
    if [ "${TARGETARCH}" = "amd64" ]; then \
        S6_FILE="s6-overlay-amd64.tar.gz"; \
        S6_SHA256="a7076cf205b331e9f8479bbb09d9df77dbb5cd8f7d12e9b74920902e0c16dd98"; \
        S6_SIG_SHA256="a0f2e744893361fbf9958dca4b6df0363851dda5ce5e91dfe85e4c2a253541c7"; \
    fi; \
    S6_VERSION="2.2.0.3" && \
    S6_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/${S6_FILE}" && \
    download.sh --url "${S6_URL}" --sha256 "${S6_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh --url "${S6_URL}.sig" --sha256 "${S6_SIG_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    gpg-receive-keys.sh --key 2536CA16DF4FCDA2 && \
    gpg "${DOWNLOAD_CACHE_DIRECTORY}/${S6_FILE}.sig" && \
    tar -xzf "${DOWNLOAD_CACHE_DIRECTORY}/${S6_FILE}" -C /  && \
    echo '' > /root/.ash_history

# Install confd
COPY confd/confd-0.15.0-linux-${TARGETARCH} /usr/local/bin/confd

# Start s6
ENTRYPOINT [ "/init" ]

LABEL License="MIT License"

# JWT_PUBLIC_KEY and JWT_PRIVATE_KEY are defined in /etc/defaults
# As Docker does not support setting multiline environment variables via ENV.
ENV \
    CONFD_BACKEND=env \
    CONFD_ENABLE_SERVICE=false \
    CONFD_LOG_LEVEL=error \
    CONFD_POLLING_INTERVAL=30 \
    ETCD_CONNECTION_TIMEOUT=0 \
    ETCD_HOST_PORT=2379 \
    ETCD_HOST=etcd \
    JWT_ADMIN_TOKEN=islandora \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_LOGGING=0 \
    TERM=xterm

COPY rootfs /
