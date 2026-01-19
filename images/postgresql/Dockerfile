# syntax=docker/dockerfile:1.20.0
FROM base

ARG TARGETARCH

EXPOSE 5432

ARG \
    # renovate: datasource=repology depName=alpine_3_22/postgresql16
    POSTGRESQL_VERSION=16.11-r0 

# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=postgresql-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        postgresql16=="${POSTGRESQL_VERSION}" \
    && \
    mkdir -p /var/lib/postgresql/data /etc/postgresql && \
    chown -R postgres:postgres /var/lib/postgresql && \
    chmod 700 /var/lib/postgresql/data && \
    cleanup.sh

ENV \
    PGDATA=/var/lib/postgresql/data

COPY --link rootfs /
