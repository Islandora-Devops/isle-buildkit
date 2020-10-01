# syntax=docker/dockerfile:experimental
FROM local/nginx:latest as composer

# Islandora based Drupal install.
RUN --mount=type=cache,target=/root/.composer/cache \
    --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    composer create-project islandora/drupal-project:8.8.1 \
        --prefer-dist \
        --no-interaction \
        --stability stable \
        --no-dev \
        --no-install \
        /var/www/drupal \
    && \
    cd /var/www/drupal && \
    composer require --update-no-dev -- \
        drupal/admin_toolbar:^2.0 \
        drupal/console:~1.0 \
        drupal/content_browser:^1.0@alpha \
        drupal/devel:^2.0 \
        drupal/facets:^1.3 \
        drupal/matomo:^1.7 \
        drupal/pdf:1.x-dev \
        drupal/rest_oai_pmh:^1.0 \
        drupal/restui:^1.16 \
        drupal/search_api_solr:^3.8 \
        drupal/transliterate_filenames:^1.3 \
        drush/drush:^9.7.1 \
        islandora-rdm/islandora_fits:dev-master \
        islandora/carapace:dev-8.x-3.x \
        islandora/islandora_defaults:dev-8.x-1.x \
        zaporylie/composer-drupal-optimizations:^1.0 \
    && \
    mkdir -p /var/www/drupal/web/libraries && \
    MASONRY_VERSION="3.3.2" && \
    MASONRY_FILE="v${MASONRY_VERSION}.zip" && \
    MASONRY_URL="https://github.com/desandro/masonry/archive/${MASONRY_FILE}" && \
    MASONRY_SHA256="85dc8b2cdf789693a14022dadc3e573a87d625da5da1cf83e1ef1e5af22af496" && \
    download.sh --url "${MASONRY_URL}" --sha256 "${MASONRY_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    unzip "${DOWNLOAD_CACHE_DIRECTORY}/${MASONRY_FILE}" -d /var/www/drupal/web/libraries && \
    mv  /var/www/drupal/web/libraries/masonry-${MASONRY_VERSION} /var/www/drupal/web/libraries/masonry && \
    PDFJS_VERSION="2.0.943" && \
    PDFJS_FILE="pdfjs-${PDFJS_VERSION}-dist.zip" && \
    PDFJS_URL="https://github.com/mozilla/pdf.js/releases/download/v${PDFJS_VERSION}/${PDFJS_FILE}" && \
    PDFJS_SHA256="381683b05f494fe28e11185f98a238b34a663b1b41b5432aa769ca493e5cd087" && \
    download.sh --url "${PDFJS_URL}" --sha256 "${PDFJS_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    mkdir -p /var/www/drupal/web/libraries/pdf.js && \
    unzip "${DOWNLOAD_CACHE_DIRECTORY}/${PDFJS_FILE}" -d /var/www/drupal/web/libraries/pdf.js && \
    OPENSEADRAGON_VERSION="2.4.2" && \
    OPENSEADRAGON_FILE="openseadragon-bin-${OPENSEADRAGON_VERSION}.zip" && \
    OPENSEADRAGON_URL="https://github.com/openseadragon/openseadragon/releases/download/v${OPENSEADRAGON_VERSION}/${OPENSEADRAGON_FILE}" && \
    OPENSEADRAGON_SHA256="8e32d808b80206d5f5aadcfc51ffecf2ecc89e5fb6876c51f409940cf4b1087e" && \
    download.sh --url "${OPENSEADRAGON_URL}" --sha256 "${OPENSEADRAGON_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    mkdir -p /var/www/drupal/web/sites/all/assets/vendor && \
    unzip "${DOWNLOAD_CACHE_DIRECTORY}/${OPENSEADRAGON_FILE}" -d /var/www/drupal/web/sites/all/assets/vendor && \
    mv "/var/www/drupal/web/sites/all/assets/vendor/${OPENSEADRAGON_FILE%.zip}" /var/www/drupal/web/sites/all/assets/vendor/openseadragon && \
    mkdir -p /var/www/drupal/web/sites/default/files/library-definitions && \
    cp /var/www/drupal/web/modules/contrib/openseadragon/openseadragon.json /var/www/drupal/web/sites/default/files/library-definitions && \
    chown -R nginx:nginx /var/www/drupal && \
    cleanup.sh

FROM local/drupal:latest

COPY --chown=nginx:nginx --from=composer /var/www/drupal /var/www/drupal

COPY rootfs /
