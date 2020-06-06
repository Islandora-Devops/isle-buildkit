# syntax=docker/dockerfile:experimental
FROM local/nginx:latest as composer

# Overwrite with your own arguments or explicitly copy in 
# your own composer.json / composer.lock files instead.
# https://getcomposer.org/doc/03-cli.md#create-project
ARG composer_project="drupal/recommended-project"

WORKDIR /build

RUN --mount=type=cache,target=/root/.composer/cache \
    composer create-project --no-install ${composer_project} /build && \
    composer require -- drush/drush && \
    composer install

FROM local/drupal:latest

RUN --mount=type=bind,from=composer,source=/build,target=/build \
    --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    DRUSH_VERSION="0.6.0" && \
    DRUSH_FILE="drush.phar" && \
    DRUSH_URL="https://github.com/drush-ops/drush-launcher/releases/download/${DRUSH_VERSION}/${DRUSH_FILE}" && \
    DRUSH_SHA256="c3f32a800a2f18470b0010cd71c49e49ef5c087f8131eecfe9b686dc1f3f3d4e" && \
    download.sh --url "${DRUSH_URL}" --sha256 "${DRUSH_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${DRUSH_FILE}" /usr/local/bin/drush && \
    chmod a+x /usr/local/bin/drush && \
    cp -r /build/* /var/www/drupal && \
    chown -R nginx:nginx /var/www/drupal && \
    cleanup.sh
