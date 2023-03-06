# syntax=docker/dockerfile:1.5.1
FROM nginx

ARG TARGETARCH

ARG MATOMO_VERSION=4.13.0
ARG MATOMO_FILE=${MATOMO_VERSION}.tar.gz
ARG MATOMO_URL=https://github.com/matomo-org/matomo/archive/refs/tags/${MATOMO_FILE}
ARG MATOMO_SHA256=064c0c9b17a8ff07c8f7bc496513e3739cc408e7e329615a4e340f5d0c7159c7

ARG EXTRA_TOOLS_VERSION=4.0.1-beta4
ARG EXTRA_TOOLS_FILE=${EXTRA_TOOLS_VERSION}.tar.gz
ARG EXTRA_TOOLS_URL=https://github.com/digitalist-se/extratools/archive/refs/tags/${EXTRA_TOOLS_FILE}
ARG EXTRA_TOOLS_SHA256=1d04ee7b871c76c9f875da100e20e9472059b2a4fe7c52830360e90f205779e2

EXPOSE 8000

WORKDIR /var/www/matomo

# Composer require statements are for supporting the Extra Tools plugin.
#
# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=matomo-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${MATOMO_URL}" \
        --sha256 "${MATOMO_SHA256}" \
        --strip \
        --dest /var/www/matomo \
    && \
    composer require -d /var/www/matomo symfony/yaml:~2.6.0 && \
    composer require -d /var/www/matomo symfony/process:^3.4 && \
    composer install -d /var/www/matomo && \
    download.sh \
        --url "${EXTRA_TOOLS_URL}" \
        --sha256 "${EXTRA_TOOLS_SHA256}" \
        --strip \
        --dest /var/www/matomo/plugins/ExtraTools && \
    cleanup.sh

# The driver is given explicitly to prevent accidentially overriding as Matomo
# only supports MySQL.
ENV \
    MATOMO_ASSUME_SECURE_PROTOCOL=1 \
    MATOMO_DB_DRIVER=mysql \
    MATOMO_DB_NAME=matomo \
    MATOMO_DB_PASSWORD=password \
    MATOMO_DB_USER=matomo \
    MATOMO_DEFAULT_HOST=https://islandora.traefik.me \
    MATOMO_DEFAULT_NAME=Islandora \
    MATOMO_DEFAULT_TIMEZONE=America/Halifax \
    MATOMO_FORCE_SSL=1 \
    MATOMO_PROXY_CLIENT_HEADERS=HTTP_X_FORWARDED_FOR \
    MATOMO_PROXY_HOST_HEADERS=HTTP_X_FORWARDED_HOST \
    MATOMO_PROXY_URI_HEADER=1 \
    MATOMO_USER_EMAIL=admin@example.org \
    MATOMO_USER_NAME=admin \
    MATOMO_USER_PASS=password

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
