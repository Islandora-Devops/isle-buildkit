# syntax=docker/dockerfile:1.5.1
FROM base

ARG TARGETARCH
ARG COMPOSER_VERSION="2.4.4"
ARG COMPOSER_FILE="composer.phar"
ARG COMPOSER_URL="https://getcomposer.org/download/${COMPOSER_VERSION}/${COMPOSER_FILE}"
ARG COMPOSER_SHA256="c252c2a2219956f88089ffc242b42c8cb9300a368fd3890d63940e4fc9652345"

WORKDIR /var/www

# https://getcomposer.org/download/
# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=download-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${COMPOSER_URL}" \
        --sha256 "${COMPOSER_SHA256}" \
    && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${COMPOSER_FILE}" /usr/bin/composer && \
    chmod a+x /usr/bin/composer && \
    cleanup.sh

# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=nginx-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        icu-data-full \
        nginx \
        php81 \
        php81-ctype \
        php81-curl \
        php81-dom \
        php81-fileinfo \
        php81-fpm \
        php81-gd \
        php81-iconv \
        php81-intl \
        php81-json \
        php81-ldap \
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
        php81-xmlreader \
        php81-xmlwriter \
        php81-xsl \
        php81-zip \
    && \
    addgroup nginx jwt && \
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

COPY --link rootfs /
