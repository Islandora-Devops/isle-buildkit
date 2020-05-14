# syntax=docker/dockerfile:experimental
FROM islandora/base:latest

RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \ 
    apk-install.sh \
        composer \
        nginx \
        php7-ctype \
        php7-curl \
        php7-dom \
        php7-fpm \
        php7-gd \
        php7-opcache \
        php7-pdo \
        php7-pdo_mysql \ 
        php7-pdo_pgsql \ 
        php7-session \
        php7-simplexml \
        php7-tokenizer \
        php7-xml \
        php7-xmlwriter \
    && \
    cleanup.sh

COPY rootfs /
