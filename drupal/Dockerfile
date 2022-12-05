# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.16.2
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

ARG DRUSH_VERSION="0.6.0"
ARG DRUSH_SHA256="c3f32a800a2f18470b0010cd71c49e49ef5c087f8131eecfe9b686dc1f3f3d4e"

RUN --mount=type=cache,id=drupal-downloads,sharing=locked,target=/opt/downloads \
    DRUSH_FILE="drush.phar" && \
    DRUSH_URL="https://github.com/drush-ops/drush-launcher/releases/download/${DRUSH_VERSION}/${DRUSH_FILE}" && \
    download.sh --url "${DRUSH_URL}" --sha256 "${DRUSH_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${DRUSH_FILE}" /usr/bin/drush && \
    chmod a+x /usr/bin/drush

FROM alpine:${alpine} AS cache
FROM ${repository}/nginx:${tag}

EXPOSE 80

RUN --mount=type=cache,id=drupal-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add \
      patch \
    && \
    mkdir -p \
        /var/www/drupal/config \
        /var/www/drupal/web/libraries \
    && \
    chown -R nginx:nginx /var/www && \
    addgroup nginx jwt && \
    cleanup.sh

# Installation typically needs more than the default 30 seconds defined in the
# base image. Set to 10 minutes just incase it ran on very old or overallocated
# hardware.
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=600000

ENV \
    DRUPAL_DEFAULT_ACCOUNT_EMAIL=webmaster@localhost.com \
    DRUPAL_DEFAULT_ACCOUNT_NAME=admin \
    DRUPAL_DEFAULT_ACCOUNT_PASSWORD=password \
    DRUPAL_DEFAULT_BROKER_HOST=activemq \
    DRUPAL_DEFAULT_BROKER_PORT=61613 \
    DRUPAL_DEFAULT_CANTALOUPE_URL=https://islandora.traefik.me/cantaloupe/iiif/2 \
    DRUPAL_DEFAULT_CONFIGDIR=/var/www/drupal/config/sync \
    DRUPAL_DEFAULT_DB_NAME=drupal_default \
    DRUPAL_DEFAULT_DB_PASSWORD=password \
    DRUPAL_DEFAULT_DB_USER=drupal_default \
    DRUPAL_DEFAULT_EMAIL=webmaster@localhost.com \
    DRUPAL_DEFAULT_FCREPO_HOST=islandora.traefik.me \
    DRUPAL_DEFAULT_FCREPO_PORT=8081 \
    DRUPAL_DEFAULT_FITS_HOST=fits \
    DRUPAL_DEFAULT_FITS_PORT=8080 \
    DRUPAL_DEFAULT_INSTALL_EXISTING_CONFIG=false \
    DRUPAL_DEFAULT_INSTALL=true \
    DRUPAL_DEFAULT_LOCALE=en \
    DRUPAL_DEFAULT_MATOMO_URL=https://islandora.traefik.me/matomo/ \
    DRUPAL_DEFAULT_NAME=Default \
    DRUPAL_DEFAULT_PROFILE=standard \
    DRUPAL_DEFAULT_SALT=9PPaL0CxZAIcq0l9wxgDGlCZrp7JdT_x7v9gVzpdbUjMt1PqDz3uD0Zy-i16DuJ1-Htuq5hqeg \
    DRUPAL_DEFAULT_SITE_URL=https://islandora.traefik.me \
    DRUPAL_DEFAULT_SOLR_CORE=ISLANDORA \
    DRUPAL_DEFAULT_SOLR_HOST=solr \
    DRUPAL_DEFAULT_SOLR_PORT=8983 \
    DRUPAL_DEFAULT_SUBDIR=default \
    DRUPAL_DEFAULT_TRIPLESTORE_HOST=blazegraph \
    DRUPAL_DEFAULT_TRIPLESTORE_NAMESPACE=islandora \
    DRUPAL_DEFAULT_TRIPLESTORE_PORT=8080 \
    DRUPAL_ENABLE_HTTPS=true \
    DRUPAL_REVERSE_PROXY_IPS= \
    DRUPAL_SITES=DEFAULT

WORKDIR /var/www/drupal

COPY --link --from=download /usr/bin/drush /usr/bin/drush

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
