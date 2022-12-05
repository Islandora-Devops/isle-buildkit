# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.16.2
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

ARG COMPOSER_VERSION="2.3.10"
ARG COMPOSER_SHA256="d808272f284fa8e0f8b470703e1438ac8f362030bbc9d12e29530277d767aff0"

# https://getcomposer.org/download/
RUN --mount=type=cache,id=download-downloads,sharing=locked,target=/opt/downloads \
    COMPOSER_FILE="composer.phar" && \
    COMPOSER_URL="https://getcomposer.org/download/${COMPOSER_VERSION}/${COMPOSER_FILE}" && \
    download.sh --url "${COMPOSER_URL}" --sha256 "${COMPOSER_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${COMPOSER_FILE}" /usr/bin/composer && \
    chmod a+x /usr/bin/composer

FROM alpine:${alpine} AS cache
FROM ${repository}/download:${tag}

# Install packages and tools that allow for basic downloads.
RUN --mount=type=cache,id=composer-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add --no-cache \
        php81 \
        php81-ctype \
        php81-curl \
        php81-dom \
        php81-fileinfo \
        php81-fpm \
        php81-gd \
        php81-iconv \
        php81-json \
        php81-mbstring \
        php81-mysqli \
        php81-opcache \
        php81-openssl \
        php81-pdo \
        php81-pdo_mysql \
        php81-pdo_pgsql \
        php81-phar \
        php81-session \
        php81-simplexml \
        php81-tokenizer \
        php81-xml \
        php81-xmlwriter \
        php81-xmlreader \
        php81-xsl \
    && \
    ln -s /usr/bin/php81 /usr/bin/php && \
    echo '' > /root/.ash_history

COPY --link --from=download /usr/bin/composer /usr/bin/composer

COPY --link rootfs /
