# syntax=docker/dockerfile:1.5.1
FROM base

ARG TARGETARCH

EXPOSE 3306

# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=mariadb-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        mariadb \
        mysql-client \
        mariadb-server-utils \
    && \
    mkdir -p /var/lib/mysql-files && \
    chown -R mysql:mysql \
        /var/lib/mysql \
        /var/lib/mysql-files \
    && \
    cleanup.sh

# Installation sometimes needs more than the default 30 seconds defined in the
# base image. Set to 10 minutes just incase it ran on very old or overallocated
# hardware.
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=600000
# Default value of 256 MB in bytes
ENV DB_MAX_ALLOWED_PACKET=268435456

COPY --link rootfs /
