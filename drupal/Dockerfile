# syntax=docker/dockerfile:experimental
FROM local/nginx:latest

RUN --mount=type=cache,target=/etc/cache/apk \
    apk-install.sh \
      patch && \
    cleanup.sh

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    DRUSH_VERSION="0.6.0" && \
    DRUSH_FILE="drush.phar" && \
    DRUSH_URL="https://github.com/drush-ops/drush-launcher/releases/download/${DRUSH_VERSION}/${DRUSH_FILE}" && \
    DRUSH_SHA256="c3f32a800a2f18470b0010cd71c49e49ef5c087f8131eecfe9b686dc1f3f3d4e" && \
    download.sh --url "${DRUSH_URL}" --sha256 "${DRUSH_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${DRUSH_FILE}" /usr/bin/drush && \
    chmod a+x /usr/bin/drush && \
    mkdir -p /var/www/drupal/config && \
    mkdir -p /var/www/drupal/web/libraries && \
    chown -R nginx:nginx /var/www && \
    mkdir -p /opt/keys/jwt && \
    chown nginx:nginx /opt/keys/jwt

WORKDIR /var/www/drupal

COPY rootfs /

EXPOSE 80
