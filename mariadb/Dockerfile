# syntax=docker/dockerfile:1.5.1
FROM base

ARG TARGETARCH

EXPOSE 3306

# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=mariadb-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        mariadb \
        mysql-client \
    && \
    mkdir -p /var/lib/mysql-files && \
    chown -R mysql:mysql \
        /var/lib/mysql \
        /var/lib/mysql-files \
    && \
    cleanup.sh

COPY --link rootfs /
