# syntax=docker/dockerfile:experimental
FROM alpine:3.11.6

# Install packages and tools required by all downstream images.
RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \
    --mount=id=downloads,type=cache,target=/opt/downloads \
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
    CONFD_VERSION="0.15.0" && \
    CONFD_SHA256="7f3aba1d803543dd1df3944d014f055112cf8dadf0a583c76dd5f46578ebe3c2" && \
    wget -N -P /opt/downloads https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz && \
    wget -N -P /opt/downloads https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz.sig && \
    gpg --keyserver hkp://keys.gnupg.net:80 --recv-key 2536CA16DF4FCDA2 && \
    gpg /opt/downloads/s6-overlay-amd64.tar.gz.sig && \
    wget -N -P /opt/downloads https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
    sha256sum /opt/downloads/confd-${CONFD_VERSION}-linux-amd64 | cut -f1 -d' ' | xargs test ${CONFD_SHA256} == && \
    tar -xzf /opt/downloads/s6-overlay-amd64.tar.gz -C / && \
    cp /opt/downloads/confd-${CONFD_VERSION}-linux-amd64 /usr/local/bin/confd && \
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
