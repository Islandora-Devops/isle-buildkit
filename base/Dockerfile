# syntax=docker/dockerfile:experimental
FROM alpine:3.12.4

COPY build/download.sh /usr/local/bin

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
    S6_VERSION="1.22.1.0" && \
    S6_FILE="s6-overlay-amd64.tar.gz" && \
    S6_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/${S6_FILE}" && \
    S6_SHA256="73f9779203310ddf9c5132546a1978e1a2b05990263b92ed2c34c1e258e2df6c" && \
    S6_SIG_SHA256="7e9c33f45bca1f89b3a1702175a4109e99c911e47ae9de62fbec013406db2b01" && \
    download.sh --url "${S6_URL}" --sha256 "${S6_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh --url "${S6_URL}.sig" --sha256 "${S6_SIG_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    tar -xzf "${DOWNLOAD_CACHE_DIRECTORY}/${S6_FILE}" -C / && \
    CONFD_VERSION="0.16.0" && \
    CONFD_URL="https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64" && \
    CONFD_SHA256="255d2559f3824dd64df059bdc533fd6b697c070db603c76aaf8d1d5e6b0cc334" && \
    download.sh --url "${CONFD_URL}" --sha256 "${CONFD_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/confd-${CONFD_VERSION}-linux-amd64" /usr/local/bin/confd && \
    chmod a+x /usr/local/bin/confd && \
    echo '' > /root/.ash_history

# Start s6
ENTRYPOINT [ "/init" ]

LABEL License="MIT License"

# https://github.com/just-containers/s6-overlay#customizing-s6-behaviour
ENV S6_LOGGING=0 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    TERM=xterm

COPY rootfs /
