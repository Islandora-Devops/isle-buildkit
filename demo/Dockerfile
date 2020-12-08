# syntax=docker/dockerfile:experimental
FROM local/nginx:latest as composer

# Islandora based Drupal install.
RUN --mount=type=cache,target=/root/.composer/cache \
    --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    # Get the Drupal codebase
    git clone https://github.com/dannylamb/islandora-sandbox && \
    mv islandora-sandbox /var/www/drupal && \
    cd /var/www/drupal && \
    composer install && \
    # Set up libraries
    mkdir -p /var/www/drupal/web/libraries && \
    # PDF.js
    PDFJS_VERSION="2.0.943" && \
    PDFJS_FILE="pdfjs-${PDFJS_VERSION}-dist.zip" && \
    PDFJS_URL="https://github.com/mozilla/pdf.js/releases/download/v${PDFJS_VERSION}/${PDFJS_FILE}" && \
    PDFJS_SHA256="381683b05f494fe28e11185f98a238b34a663b1b41b5432aa769ca493e5cd087" && \
    download.sh --url "${PDFJS_URL}" --sha256 "${PDFJS_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    mkdir -p /var/www/drupal/web/libraries/pdf.js && \
    unzip "${DOWNLOAD_CACHE_DIRECTORY}/${PDFJS_FILE}" -d /var/www/drupal/web/libraries/pdf.js && \
    # Openseadragon
    mkdir -p /var/www/drupal/web/sites/default/files/library-definitions && \
    cp /var/www/drupal/web/modules/contrib/openseadragon/openseadragon.json /var/www/drupal/web/sites/default/files/library-definitions && \
    chown -R nginx:nginx /var/www/drupal && \
    cleanup.sh

FROM local/drupal:latest

COPY --chown=nginx:nginx --from=composer /var/www/drupal /var/www/drupal

COPY rootfs /
