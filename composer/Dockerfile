# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download 

# https://getcomposer.org/download/
RUN --mount=type=cache,id=download-downloads,sharing=locked,target=/opt/downloads \
    COMPOSER_VERSION="2.0.4" && \
    COMPOSER_FILE="composer.phar" && \
    COMPOSER_URL="https://getcomposer.org/download/${COMPOSER_VERSION}/${COMPOSER_FILE}" && \
    COMPOSER_SHA256="c3b2bc477429c923c69f7f9b137e06b2a93c6a1e192d40ffad1741ee5d54760d" && \
    download.sh --url "${COMPOSER_URL}" --sha256 "${COMPOSER_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${COMPOSER_FILE}" /usr/bin/composer && \
    chmod a+x /usr/bin/composer

FROM alpine:3.13.2 AS cache
FROM ${repository}/download:${tag}

# Install packages and tools that allow for basic downloads.
RUN --mount=type=cache,id=composer-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add --no-cache \
        php7 \
        php7-ctype \
        php7-curl \
        php7-dom \
        php7-fileinfo \
        php7-fpm \
        php7-gd \
        php7-iconv \
        php7-json \
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
        php7-xmlwriter \
        php7-xmlreader \
        php7-xsl \
    && \
    echo '' > /root/.ash_history

COPY --from=download /usr/bin/composer /usr/bin/composer

COPY rootfs /
