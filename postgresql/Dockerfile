# syntax=docker/dockerfile:1.5.1
FROM base

ARG TARGETARCH

EXPOSE 5432

ARG \
    # renovate: datasource=repology depName=alpine_3_23/postgresql18
    POSTGRESQL_VERSION=18.1-r0

# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=postgresql-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        postgresql18=="${POSTGRESQL_VERSION}" \
    && \
    mkdir -p /var/lib/postgresql/data /etc/postgresql && \
    chown -R postgres:postgres /var/lib/postgresql && \
    chmod 700 /var/lib/postgresql/data && \
    cleanup.sh

ENV \
    DB_HOST=postgresql \
    DB_PORT=5432 \
    PGDATA=/var/lib/postgresql/data

COPY --link rootfs /
