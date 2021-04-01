# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM alpine:3.13.2 AS cache
FROM ${repository}/base:${tag}

EXPOSE 3306

RUN --mount=type=cache,id=mariadb-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add \
        mariadb \
        mysql-client \
    && \
    mkdir -p /var/lib/mysql-files && \
    chown -R mysql:mysql /var/lib/mysql && \
    chown -R mysql:mysql /var/lib/mysql-files && \
    cleanup.sh

COPY rootfs /
