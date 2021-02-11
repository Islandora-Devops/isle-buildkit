# syntax=docker/dockerfile:1.2.1
FROM local/base:latest

RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \ 
    apk-install.sh \
        postgresql \
        postgresql-client \
    && \
    mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql && \
    chmod 700 /var/lib/postgresql/data && \
    mkdir -p /etc/postgresql && \
    cleanup.sh

ENV PGDATA /var/lib/postgresql/data

EXPOSE 5432

COPY rootfs /
