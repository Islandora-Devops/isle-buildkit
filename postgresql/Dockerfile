# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.16.2
FROM alpine:${alpine} AS cache
FROM ${repository}/base:${tag}

EXPOSE 5432

RUN --mount=type=cache,id=postgresql-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add \
        postgresql \
        postgresql-client \
    && \
    mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql && \
    chmod 700 /var/lib/postgresql/data && \
    mkdir -p /etc/postgresql && \
    cleanup.sh

ENV \
    PGDATA=/var/lib/postgresql/data

COPY --link rootfs /
