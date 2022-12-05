# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.16.2
FROM ${repository}/download:${tag} AS download
FROM alpine:${alpine} AS cache
FROM alpine:${alpine}

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
        procps \
        util-linux \
    && \
    addgroup -g 2000 jwt && \
    echo '' > /root/.ash_history

ARG TARGETARCH

COPY --link --from=download /usr/local/bin/*.sh /usr/local/bin/

ARG S6_VERSION="3.1.2.1"
ARG S6_OVERLAY_AMD64_SHA256="6019b6b06cfdbb1d1cd572d46b9b158a4904fd19ca59d374de4ddaaa6a3727d5"
ARG S6_OVERLAY_ARM64_SHA256="e73f9a021b64f88278830742149c14ef8a52331102881ba025bf32a66a0e7c78"
ARG S6_OVERLAY_NOARCH_SHA256="cee89d3eeabdfe15239b2c5c3581d9352d2197d4fd23bba3f1e64bf916ccf496"
ARG S6_OVERLAY_SYMLINKS_ARCH_SHA256="1b75ac96ddc953f6b7b10be4f579c3e4f6cdf85270116a539930e03e74066f2f"
ARG S6_OVERLAY_SYMLINKS_NOARCH_SHA256="1e36efb936084fddffe6c55dae8f478e7b2d70f77db2caaceb78c7425b9a7956"

# Install s6
RUN --mount=type=cache,id=base-downloads,sharing=locked,from=download,target=/opt/downloads \
    S6_BASE_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}" && \
    S6_OVERLAY_NOARCH=s6-overlay-noarch.tar.xz && \
    download.sh --url "${S6_BASE_URL}/${S6_OVERLAY_NOARCH}" --sha256 "${S6_OVERLAY_NOARCH_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    tar -xf "${DOWNLOAD_CACHE_DIRECTORY}/${S6_OVERLAY_NOARCH}" -C /  && \
    S6_OVERLAY_SYMLINKS_ARCH=s6-overlay-symlinks-arch.tar.xz && \
    download.sh --url "${S6_BASE_URL}/${S6_OVERLAY_SYMLINKS_ARCH}" --sha256 "${S6_OVERLAY_SYMLINKS_ARCH_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    tar -xf "${DOWNLOAD_CACHE_DIRECTORY}/${S6_OVERLAY_SYMLINKS_ARCH}" -C /  && \
    S6_OVERLAY_SYMLINKS_NOARCH=s6-overlay-symlinks-noarch.tar.xz && \
    download.sh --url "${S6_BASE_URL}/${S6_OVERLAY_SYMLINKS_NOARCH}" --sha256 "${S6_OVERLAY_SYMLINKS_NOARCH_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    tar -xf "${DOWNLOAD_CACHE_DIRECTORY}/${S6_OVERLAY_SYMLINKS_NOARCH}" -C /  && \
    if [ "${TARGETARCH}" = "arm64" ]; then \
        S6_FILE="s6-overlay-aarch64.tar.xz"; \
        S6_SHA256="${S6_OVERLAY_ARM64_SHA256}"; \
    fi; \
    if [ "${TARGETARCH}" = "amd64" ]; then \
        S6_FILE="s6-overlay-x86_64.tar.xz"; \
        S6_SHA256="${S6_OVERLAY_AMD64_SHA256}"; \
    fi; \
    download.sh --url "${S6_BASE_URL}/${S6_FILE}" --sha256 "${S6_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    tar -xf "${DOWNLOAD_CACHE_DIRECTORY}/${S6_FILE}" -C /  && \
    echo '' > /root/.ash_history

# Install confd
COPY --link confd/confd-0.15.0-linux-${TARGETARCH} /usr/local/bin/confd

# Start s6
ENTRYPOINT [ "/init" ]

LABEL License="MIT License"

ENV \
    CERTIFICATE_AUTHORITY=/usr/local/share/ca-certificates/rootCA.pem \
    CERTIFICATE=/usr/local/share/ca-certificates/cert.pem \
    CONFD_BACKEND=env \
    CONFD_ENABLE_SERVICE=false \
    CONFD_LOG_LEVEL=error \
    CONFD_POLLING_INTERVAL=30 \
    ETCD_CONNECTION_TIMEOUT=10 \
    ETCD_HOST=etcd \
    ETCD_PORT=2379 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICE=1 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=30000 \
    S6_SERVICES_GRACETIME=30000 \
    S6_LOGGING=0 \
    TERM=xterm

# CERT_AUTHORITY and CERT_PUBLIC as well as JWT_PUBLIC_KEY and JWT_PRIVATE_KEY
# are defined in /etc/defaults. As Docker does not support setting multiline
# environment variables via ENV. The 'DB' environment variables can be
# overridden by prefixing it with the image name i.e. `FCREPO_DB_NAME` would
# override the value for `DB_NAME`.
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

COPY --link rootfs /
