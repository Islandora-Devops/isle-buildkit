# syntax=docker/dockerfile:experimental
FROM local/nginx:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    MATOMO_VERSION=3.13.5 && \
    MATOMO_FILE=matomo-${MATOMO_VERSION}.tar.gz && \
    wget -N -P /opt/downloads https://builds.matomo.org/${MATOMO_FILE} && \
    wget -N -P /opt/downloads https://builds.matomo.org/${MATOMO_FILE}.asc && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 814E346FA01A20DBB04B6807B5DBD5925590A237 && \
    gpg --verify /opt/downloads/${MATOMO_FILE}.asc /opt/downloads/${MATOMO_FILE} && \
    tar -xzf /opt/downloads/${MATOMO_FILE} -C /opt && \
    chown -R nginx:nginx /opt/matomo && \
    cleanup.sh

WORKDIR /opt/matomo

VOLUME [ "/opt/matomo/config" ]

COPY rootfs /

EXPOSE 8000
