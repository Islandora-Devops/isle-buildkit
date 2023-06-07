# syntax=docker/dockerfile:1.5.1
FROM nginx

ARG TARGETARCH

ARG MATOMO_VERSION=4.14.2
ARG MATOMO_FILE=${MATOMO_VERSION}.tar.gz
ARG MATOMO_URL=https://builds.matomo.org/matomo-${MATOMO_FILE}
ARG MATOMO_SHA256=8cfb3fe1b82ded5a9e4a878b9f01ebf85238dba84087088ff117224033700a9a

ARG EXTRA_TOOLS_VERSION=4.1.0-beta5
ARG EXTRA_TOOLS_FILE=${EXTRA_TOOLS_VERSION}.tar.gz
ARG EXTRA_TOOLS_URL=https://github.com/digitalist-se/extratools/archive/refs/tags/${EXTRA_TOOLS_FILE}
ARG EXTRA_TOOLS_SHA256=ce9c9f1d01aaf04e3dfded21d6b9080c1fda633535295dc1c8cd0427bcdc826f

EXPOSE 8000

WORKDIR /var/www/matomo

# Composer require statements are for supporting the Extra Tools plugin.
#
# Platform agnostic does not require arch specific identifier.
# IP to City Lite - opensource monthly geolocation database - expires after three months - will be refreshed with latest upon every build
RUN --mount=type=cache,id=matomo-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${MATOMO_URL}" \
        --sha256 "${MATOMO_SHA256}" \
        --strip \
        --dest /var/www/matomo \
    && \
    wget --directory-prefix=/var/www/matomo "https://raw.githubusercontent.com/matomo-org/matomo/${MATOMO_VERSION}/composer.json" && \
    wget --directory-prefix=/var/www/matomo "https://raw.githubusercontent.com/matomo-org/matomo/${MATOMO_VERSION}/composer.lock" && \
    composer require -d /var/www/matomo symfony/yaml:~2.6.0 && \
    composer require -d /var/www/matomo symfony/process:^5.4 && \
    composer install -d /var/www/matomo && \
    download.sh \
        --url "${EXTRA_TOOLS_URL}" \
        --sha256 "${EXTRA_TOOLS_SHA256}" \
        --strip \
        --dest /var/www/matomo/plugins/ExtraTools && \
    curl https://download.db-ip.com/free/dbip-city-lite-`date +%Y`-`date +%m`.mmdb.gz > /tmp/dbip.mmdb.gz && \
	gunzip -f /tmp/dbip.mmdb.gz && \
	mv /tmp/dbip.mmdb /var/www/matomo/misc/DBIP-City.mmdb && \
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
