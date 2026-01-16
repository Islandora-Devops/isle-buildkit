# syntax=docker/dockerfile:1.5.1
FROM base

ARG TARGETARCH

EXPOSE 3306

ARG \
  # renovate: datasource=repology depName=alpine_3_22/mariadb
  MARIADB_VERSION=11.4.8-r0

# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=mariadb-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        mariadb=="${MARIADB_VERSION}" \
        mariadb-server-utils=="${MARIADB_VERSION}" \
    && \
    mkdir -p \
        /var/lib/mysql \
        /var/lib/mysql-files \
    && \
    chown -R mysql:mysql \
        /var/lib/mysql \
        /var/lib/mysql-files \
    && \
    cleanup.sh

# Installation sometimes needs more than the default 30 seconds defined in the
# base image. Set to 10 minutes just incase it ran on very old or overallocated
# hardware.
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=600000

ENV \
    # Default Mariadb value of 16 MB (bytes)
    MYSQL_MAX_ALLOWED_PACKET=16777216 \
    MYSQL_TRANSACTION_ISOLATION=READ-COMMITTED

COPY --link rootfs /

HEALTHCHECK CMD mysqladmin ping --socket=/var/run/mysqld/mysqld.sock | grep -q alive || exit 1
