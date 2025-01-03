# syntax=docker/dockerfile:1.5.1
FROM alpine

ARG TARGETARCH
# renovate: datasource=github-releases depName=s6-overlay packageName=just-containers/s6-overlay
ARG S6_VERSION=3.2.0.0
ARG S6_BASE_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}"
ARG S6_OVERLAY_NOARCH=s6-overlay-noarch.tar.xz
ARG S6_OVERLAY_NOARCH_SHA256="4b0c0907e6762814c31850e0e6c6762c385571d4656eb8725852b0b1586713b6"
ARG S6_OVERLAY_SYMLINKS_ARCH=s6-overlay-symlinks-arch.tar.xz
ARG S6_OVERLAY_SYMLINKS_ARCH_SHA256="5a3f416a082daa498fb77afad1fcaac382ae0990ddd7745ce9ead7308cc23da1"
ARG S6_OVERLAY_SYMLINKS_NOARCH=s6-overlay-symlinks-noarch.tar.xz
ARG S6_OVERLAY_SYMLINKS_NOARCH_SHA256="598ab9ef6b62809727f0242e895b2c054c3d95f2d3235109856d843a96a47680"
ARG S6_OVERLAY_AMD64=s6-overlay-x86_64.tar.xz
ARG S6_OVERLAY_AMD64_SHA256="ad982a801bd72757c7b1b53539a146cf715e640b4d8f0a6a671a3d1b560fe1e2"
ARG S6_OVERLAY_ARM64=s6-overlay-aarch64.tar.xz
ARG S6_OVERLAY_ARM64_SHA256="868973e98210257bba725ff5b17aa092008c9a8e5174499e38ba611a8fc7e473"

LABEL License="MIT License"

# Start s6
ENTRYPOINT [ "/init" ]

# Install packages and tools required by all downstream images.
# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=base-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk add \
        bash \
        curl \
        git \
        gnupg \
        gzip \
        jq \
        mariadb-client \
        mysql-client \
        netcat-openbsd \
        openssl \
        patch \
        postgresql-client \
        procps \
        shadow \
        util-linux \
        wget \
        yq \
    && \
    addgroup -g 2000 jwt && \
    echo '' > /root/.ash_history

ENV DOWNLOAD_CACHE_DIRECTORY=/opt/downloads

# Install s6.
RUN --mount=type=bind,source=rootfs/usr/local/bin/download.sh,target=/usr/local/bin/download.sh \
    --mount=type=cache,id=base-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${S6_BASE_URL}/${S6_OVERLAY_NOARCH}" \
        --sha256 "${S6_OVERLAY_NOARCH_SHA256}" \
        --dest / \
    && \
    download.sh \
        --url "${S6_BASE_URL}/${S6_OVERLAY_SYMLINKS_ARCH}" \
        --sha256 "${S6_OVERLAY_SYMLINKS_ARCH_SHA256}" \
        --dest / \
    && \
    download.sh \
        --url "${S6_BASE_URL}/${S6_OVERLAY_SYMLINKS_NOARCH}" \
        --sha256 "${S6_OVERLAY_SYMLINKS_NOARCH_SHA256}" \
        --dest / \
    && \
    echo '' > /root/.ash_history

RUN --mount=type=bind,source=rootfs/usr/local/bin/download.sh,target=/usr/local/bin/download.sh \
    --mount=type=cache,id=base-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    if [ "${TARGETARCH}" = "amd64" ]; \
    then \
        download.sh \
            --url "${S6_BASE_URL}/${S6_OVERLAY_AMD64}" \
            --sha256 "${S6_OVERLAY_AMD64_SHA256}" \
            --dest / ; \
    else \
        download.sh \
            --url "${S6_BASE_URL}/${S6_OVERLAY_ARM64}" \
            --sha256 "${S6_OVERLAY_ARM64_SHA256}" \
            --dest / ; \
    fi && \
    echo '' > /root/.ash_history

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

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
    S6_LOGGING=0 \
    S6_SERVICES_GRACETIME=30000 \
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
    DEVELOPMENT_ENVIRONMENT=false \
    JWT_ADMIN_TOKEN=islandora \
    UID=

COPY --link rootfs /

# Install confd
COPY --link confd/confd-0.15.0-linux-${TARGETARCH} /usr/local/bin/confd
