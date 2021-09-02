# syntax=docker/dockerfile:experimental
FROM local/base:latest

RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \ 
    apk-install.sh \
        nginx \
        composer \
        gnu-libiconv \
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
        php7-pdo_sqlite \
        php7-phar \
        php7-session \
        php7-simplexml \
        php7-sqlite3 \
        php7-tokenizer \
        php7-xml \
        php7-xmlwriter \
        php7-xmlreader \
        php7-xsl \
        php7-yaml \
        php7-zip \
    && \
    composer self-update --2 && \
    cleanup.sh

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

COPY rootfs /

RUN mkdir /var/sqlite && chmod 750 /var/sqlite && chown nginx:nginx /var/sqlite
