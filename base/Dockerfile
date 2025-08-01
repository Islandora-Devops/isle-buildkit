# syntax=docker/dockerfile:1.5.1
FROM alpine

ARG TARGETARCH
# renovate: datasource=github-releases depName=s6-overlay packageName=just-containers/s6-overlay
ARG S6_VERSION=3.2.1.0
ARG S6_BASE_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}"
ARG S6_OVERLAY_NOARCH=s6-overlay-noarch.tar.xz
ARG S6_OVERLAY_NOARCH_SHA256="42e038a9a00fc0fef70bf0bc42f625a9c14f8ecdfe77d4ad93281edf717e10c5"
ARG S6_OVERLAY_SYMLINKS_ARCH=s6-overlay-symlinks-arch.tar.xz
ARG S6_OVERLAY_SYMLINKS_ARCH_SHA256="c99a8c5747866aedf268067c2dadd755863044c4df76429314f5f0434200c9d5"
ARG S6_OVERLAY_SYMLINKS_NOARCH=s6-overlay-symlinks-noarch.tar.xz
ARG S6_OVERLAY_SYMLINKS_NOARCH_SHA256="5c0a28acc0aca6c86d90c9cd752361e0b69b0d57789064fbc8b066b2e21264d4"
ARG S6_OVERLAY_AMD64=s6-overlay-x86_64.tar.xz
ARG S6_OVERLAY_AMD64_SHA256="8bcbc2cada58426f976b159dcc4e06cbb1454d5f39252b3bb0c778ccf71c9435"
ARG S6_OVERLAY_ARM64=s6-overlay-aarch64.tar.xz
ARG S6_OVERLAY_ARM64_SHA256="c8fd6b1f0380d399422fc986a1e6799f6a287e2cfa24813ad0b6a4fb4fa755cc"

LABEL License="MIT License"

# Start s6
ENTRYPOINT [ "/init" ]

ARG \
  # renovate: datasource=repology depName=alpine_3_20/bash
  BASH_VERSION=5.2.26-r0 \
  # renovate: datasource=repology depName=alpine_3_20/curl
  CURL_VERSION=8.12.1-r0 \
  # renovate: datasource=repology depName=alpine_3_20/git
  GIT_VERSION=2.45.4-r0 \
  # renovate: datasource=repology depName=alpine_3_20/gnupg
  GNUPG_VERSION=2.4.5-r0 \
  # renovate: datasource=repology depName=alpine_3_20/gzip
  GZIP_VERSION=1.13-r0 \
  # renovate: datasource=repology depName=alpine_3_20/jq
  JQ_VERSION=1.7.1-r0 \
  # renovate: datasource=repology depName=alpine_3_20/mariadb-client
  MARIADB_CLIENT_VERSION=10.11.11-r0 \
  # renovate: datasource=repology depName=alpine_3_20/mysql-client
  MYSQL_CLIENT_VERSION=10.11.11-r0 \
  # renovate: datasource=repology depName=alpine_3_20/netcat-openbsd	
  NETCAT_OPENBSD_VERSION=1.226-r0 \
  # renovate: datasource=repology depName=alpine_3_20/openssl
  OPENSSL_VERSION=3.3.4-r0 \
  # renovate: datasource=repology depName=alpine_3_20/patch
  PATCH_VERSION=2.7.6-r10 \
  # renovate: datasource=repology depName=alpine_3_20/postgresql16-client
  POSTGRES_CLIENT_VERSION=16.9-r0 \
  # renovate: datasource=repology depName=alpine_3_20/procps-ng
  PROCPS_VERSION=4.0.4-r0 \
  # renovate: datasource=repology depName=alpine_3_20/shadow
  SHADOW_VERSION=4.15.1-r0 \
  # renovate: datasource=repology depName=alpine_3_20/util-linux
  UTIL_LINUX_VERSION=2.40.1-r1 \
  # renovate: datasource=repology depName=alpine_3_20/wget
  WGET_VERSION=1.24.5-r0 \
  # renovate: datasource=repology depName=alpine_3_20/yq-go
  YQ_VERSION=4.44.1-r2

# Install packages and tools required by all downstream images.
# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=base-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk add \
        bash=="${BASH_VERSION}" \
        curl=="${CURL_VERSION}" \
        git=="${GIT_VERSION}" \
        gnupg=="${GNUPG_VERSION}" \
        gzip=="${GZIP_VERSION}" \
        jq=="${JQ_VERSION}" \
        mariadb-client=="${MARIADB_CLIENT_VERSION}" \
        mysql-client=="${MYSQL_CLIENT_VERSION}" \
        netcat-openbsd=="${NETCAT_OPENBSD_VERSION}" \
        openssl=="${OPENSSL_VERSION}" \
        patch=="${PATCH_VERSION}" \
        postgresql16-client=="${POSTGRES_CLIENT_VERSION}" \
        procps=="${PROCPS_VERSION}" \
        shadow=="${SHADOW_VERSION}" \
        util-linux=="${UTIL_LINUX_VERSION}" \
        wget=="${WGET_VERSION}" \
        yq=="${YQ_VERSION}" \
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
