# syntax=docker/dockerfile:1.2.1
ARG alpine=3.15.0
FROM alpine:${alpine} AS cache
FROM alpine:${alpine}

# Install packages and tools that allow for basic downloads.
RUN --mount=type=cache,id=download-apk,sharing=locked,from=cache,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk add \
        bash \
        curl \
        git \
        gnupg \
        openssl \
        patch \
        wget \
    && \
    echo '' > /root/.ash_history

ENV DOWNLOAD_CACHE_DIRECTORY=/opt/downloads \
    TERM=xterm

COPY rootfs /
