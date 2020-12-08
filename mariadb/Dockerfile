# syntax=docker/dockerfile:experimental
FROM local/base:latest

RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \ 
    apk-install.sh \
        mariadb \
        mysql-client \
    && \
    mkdir -p /var/lib/mysql-files && \
    chown -R mysql:mysql /var/lib/mysql && \
    chown -R mysql:mysql /var/lib/mysql-files && \
    cleanup.sh

EXPOSE 3306

ENV MYSQL_ROOT_PASSWORD=password

COPY rootfs /
