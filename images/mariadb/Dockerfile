# syntax=docker/dockerfile:1.20.0
# Upstream builds its Ubuntu packages and publishes this multi-architecture image.
FROM mariadb:11.8.9@sha256:f16d7a344413e519dff518f27bdb221388f84b0d274c97c4fb5f2cb0dc1b34fa

# s6-overlay and confd are static; retain ISLE startup/secrets without copying
# Alpine's musl-linked utilities or database packages into this glibc runtime.
COPY --from=base /package /package
COPY --from=base /command /command
COPY --from=base /init /init
COPY --from=base /etc/s6-overlay /etc/s6-overlay
COPY --from=base /etc/defaults /etc/defaults
COPY --from=base /etc/confd /etc/confd
COPY --from=base /usr/local/bin /usr/local/bin
COPY --from=base /usr/local/share/isle /usr/local/share/isle
COPY --from=base /usr/local/share/s6 /usr/local/share/s6

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl jq netcat-openbsd && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -g 2000 jwt && \
    mkdir -p /var/lib/mysql-files /opt/keys/jwt /run/secrets && \
    chown mysql:mysql /var/lib/mysql-files && \
    ln -s /usr/bin/mariadb /usr/local/bin/mysql && \
    ln -s /usr/bin/mariadb-admin /usr/local/bin/mysqladmin && \
    ln -s /usr/bin/mariadb-install-db /usr/local/bin/mysql_install_db && \
    ln -s /usr/sbin/mariadbd /usr/local/bin/mysqld && \
    printf '\n!includedir /etc/my.cnf.d/\n' >> /etc/mysql/mariadb.cnf && \
    mkdir -p /etc/my.cnf.d

# Match base runtime defaults; these must be ENV values for early s6 startup.
ENV \
    CERTIFICATE_AUTHORITY=/usr/local/share/ca-certificates/rootCA.pem \
    CERTIFICATE=/usr/local/share/ca-certificates/cert.pem \
    CONFD_BACKEND=env \
    CONFD_ENABLE_SERVICE=false \
    CONFD_LOG_LEVEL=error \
    CONFD_POLLING_INTERVAL=30 \
    ETCD_CONNECTION_TIMEOUT=10 \
    ETCD_HOST=etcd \
    ETCD_PORT=2379 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICE=1 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=600000 \
    S6_LOGGING=0 \
    S6_SERVICES_GRACETIME=30000 \
    TERM=xterm

# CERT_AUTHORITY and CERT_PUBLIC as well as JWT_PUBLIC_KEY and JWT_PRIVATE_KEY
# are defined in /etc/defaults. As Docker does not support setting multiline
# environment variables via ENV. The 'DB' environment variables can be
# overridden by prefixing it with the image name i.e. `FCREPO_DB_NAME` would
# override the value for `DB_NAME`.
ENV \
    DB_DRIVER=mysql \
    DB_HOST= \
    DB_MYSQL_HOST=mariadb \
    DB_MYSQL_PORT=3306 \
    DB_NAME=default \
    DB_PASSWORD=password \
    DB_PORT= \
    DB_POSTGRESQL_HOST=postgresql \
    DB_POSTGRESQL_PORT=5432 \
    DB_ROOT_PASSWORD=password \
    DB_ROOT_USER=root \
    DB_USER=default \
    DEVELOPMENT_ENVIRONMENT=false \
    JWT_ADMIN_TOKEN=islandora \
    UID=

ENV PATH="/command:${PATH}" \
    MYSQL_MAX_ALLOWED_PACKET=16777216 \
    MYSQL_TRANSACTION_ISOLATION=READ-COMMITTED

COPY --link rootfs /

ENTRYPOINT ["/init"]
CMD []
STOPSIGNAL SIGTERM
EXPOSE 3306
HEALTHCHECK CMD mysqladmin ping --socket=/var/run/mysqld/mysqld.sock | grep -q alive
