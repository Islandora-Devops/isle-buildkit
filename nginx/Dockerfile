# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM alpine:3.15.0 AS cache
FROM --platform=$BUILDPLATFORM ${repository}/composer:${tag} AS composer
FROM ${repository}/base:${tag}

RUN --mount=type=cache,id=nginx-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add \
        nginx \
        php7 \
        php7-ctype \
        php7-curl \
        php7-dom \
        php7-fileinfo \
        php7-fpm \
        php7-gd \
        php7-iconv \
        php7-intl \
        php7-json \
        php7-ldap \
        php7-mbstring \
        php7-mysqli \
        php7-opcache \
        php7-openssl \
        php7-pdo \
        php7-pdo_mysql \
        php7-pdo_pgsql \
        php7-phar \
        php7-session \
        php7-simplexml \
        php7-tokenizer \
        php7-xml \
        php7-xmlreader \
        php7-xmlwriter \
        php7-xsl \
        php7-zip \
    && \
    cleanup.sh

ENV \
    NGINX_CLIENT_BODY_TIMEOUT=60s \
    NGINX_CLIENT_MAX_BODY_SIZE=0 \
    NGINX_ERROR_LOG_LEVEL=warn \
    NGINX_FASTCGI_CONNECT_TIMEOUT=60s \
    NGINX_FASTCGI_READ_TIMEOUT=60s \
    NGINX_FASTCGI_SEND_TIMEOUT=60s \
    NGINX_KEEPALIVE_TIMEOUT=75s \
    NGINX_LINGERING_TIMEOUT=5s \
    NGINX_PROXY_CONNECT_TIMEOUT=60s \
    NGINX_PROXY_READ_TIMEOUT=60s \
    NGINX_PROXY_SEND_TIMEOUT=60s \
    NGINX_SEND_TIMEOUT=60s \
    NGINX_WORKER_CONNECTIONS=1024 \
    NGINX_WORKER_PROCESSES=auto \
    PHP_DEFAULT_SOCKET_TIMEOUT=60 \
    PHP_LOG_LEVEL=notice \
    PHP_LOG_LIMIT=16384 \
    PHP_MAX_EXECUTION_TIME=30 \
    PHP_MAX_FILE_UPLOADS=20 \
    PHP_MAX_INPUT_TIME=60 \
    PHP_MAX_INPUT_VARS=3000 \
    PHP_MEMORY_LIMIT=256M \
    PHP_POST_MAX_SIZE=128M \
    PHP_PROCESS_CONTROL_TIMEOUT=60 \
    PHP_REQUEST_TERMINATE_TIMEOUT=60 \
    PHP_UPLOAD_MAX_FILESIZE=128M

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY rootfs /
