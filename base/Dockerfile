# syntax=docker/dockerfile:1.5.1
FROM alpine

ARG TARGETARCH
ARG S6_VERSION="3.1.6.2"
ARG S6_BASE_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}"
ARG S6_OVERLAY_NOARCH=s6-overlay-noarch.tar.xz
ARG S6_OVERLAY_NOARCH_SHA256="05af2536ec4fb23f087a43ce305f8962512890d7c71572ed88852ab91d1434e3"
ARG S6_OVERLAY_SYMLINKS_ARCH=s6-overlay-symlinks-arch.tar.xz
ARG S6_OVERLAY_SYMLINKS_ARCH_SHA256="532507ac3eb81b3ce5c7fb76b57a3b61f6a583970de44e76aa43a0eb9a656cbd"
ARG S6_OVERLAY_SYMLINKS_NOARCH=s6-overlay-symlinks-noarch.tar.xz
ARG S6_OVERLAY_SYMLINKS_NOARCH_SHA256="dfa08e1600a4d119621178e09c5a899df6d4c613e4a0082c01b12a51d21fe84c"
ARG S6_OVERLAY_AMD64=s6-overlay-x86_64.tar.xz
ARG S6_OVERLAY_AMD64_SHA256="95081f11c56e5a351e9ccab4e70c2b1c3d7d056d82b72502b942762112c03d1c"
ARG S6_OVERLAY_ARM64=s6-overlay-aarch64.tar.xz
ARG S6_OVERLAY_ARM64_SHA256="3fc0bae418a0e3811b3deeadfca9cc2f0869fb2f4787ab8a53f6944067d140ee"

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
