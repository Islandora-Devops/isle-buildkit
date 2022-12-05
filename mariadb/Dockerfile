# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.16.2
FROM alpine:${alpine} AS cache
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

COPY --link rootfs /
