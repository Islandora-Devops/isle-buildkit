# syntax=docker/dockerfile:1.2.1
FROM alpine:3.13.2 AS cache
FROM alpine:3.13.2

# Install packages and tools that allow for basic downloads.
RUN --mount=type=cache,id=download-apk,sharing=locked,from=cache,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk add \
        bash \
        curl \
        git \
        gnupg \
        openssl \
        wget \
    && \
    echo '' > /root/.ash_history

ENV DOWNLOAD_CACHE_DIRECTORY=/opt/downloads \
    TERM=xterm

COPY rootfs /
