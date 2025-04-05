# syntax=docker/dockerfile:1.5.1
FROM base

ARG TARGETARCH
# renovate: datasource=github-releases depName=custom-composer packageName=composer/composer
ARG COMPOSER_VERSION=2.8.8
ARG COMPOSER_FILE=composer.phar
ARG COMPOSER_URL=https://getcomposer.org/download/${COMPOSER_VERSION}/${COMPOSER_FILE}
ARG COMPOSER_SHA256="957263e284b9f7a13d7f475dc65f3614d151b0c4dcc7e8761f7e7f749447fb68"

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

ARG \
    # renovate: datasource=repology depName=alpine_3_20/icu-data-full
    ICU_VERSION=74.2-r0 \
    # renovate: datasource=repology depName=alpine_3_20/nginx
    NGINX_VERSION=1.26.3-r0	\
    # renovate: datasource=repology depName=alpine_3_20/php83
    PHP_VERSION=8.3.15-r0

# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=nginx-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        icu-data-full=="${ICU_VERSION}" \
        nginx=="${NGINX_VERSION}" \
        php83=="${PHP_VERSION}" \
        php83-ctype=="${PHP_VERSION}" \
        php83-curl=="${PHP_VERSION}" \
        php83-dom=="${PHP_VERSION}" \
        php83-fileinfo=="${PHP_VERSION}" \
        php83-fpm=="${PHP_VERSION}" \
        php83-gd=="${PHP_VERSION}" \
        php83-iconv=="${PHP_VERSION}" \
        php83-intl=="${PHP_VERSION}" \
        php83-ldap=="${PHP_VERSION}" \
        php83-mbstring=="${PHP_VERSION}" \
        php83-mysqli=="${PHP_VERSION}" \
        php83-opcache=="${PHP_VERSION}" \
        php83-openssl=="${PHP_VERSION}" \
        php83-pdo=="${PHP_VERSION}" \
        php83-pdo_mysql=="${PHP_VERSION}" \
        php83-pdo_pgsql=="${PHP_VERSION}" \
        php83-phar=="${PHP_VERSION}" \
        php83-session=="${PHP_VERSION}" \
        php83-simplexml=="${PHP_VERSION}" \
        php83-sockets=="${PHP_VERSION}" \
        php83-tokenizer=="${PHP_VERSION}" \
        php83-xml=="${PHP_VERSION}" \
        php83-xmlreader=="${PHP_VERSION}" \
        php83-xmlwriter=="${PHP_VERSION}" \
        php83-xsl=="${PHP_VERSION}" \
        php83-zip=="${PHP_VERSION}" \
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
    NGINX_REAL_IP_HEADER=X-Forwarded-For \
    NGINX_REAL_IP_RECURSIVE=off \
    NGINX_SEND_TIMEOUT=60s \
    NGINX_SET_REAL_IP_FROM=172.0.0.0/8 \
    NGINX_SET_REAL_IP_FROM2=172.0.0.0/8 \
    NGINX_SET_REAL_IP_FROM3=172.0.0.0/8 \
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
    PHP_UPLOAD_MAX_FILESIZE=128M \
    SOLR_HOCR_PLUGIN_PATH=/opt/solr/server/solr/contrib/ocrhighlighting/lib

COPY --link rootfs /

HEALTHCHECK CMD curl -s http://localhost/status | grep -q pool
