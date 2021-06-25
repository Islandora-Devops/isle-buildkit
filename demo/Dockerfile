# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/composer:${tag} AS composer

ARG COMMIT=c4a7574e39ba07e1baa51a0d145da1328e7d9ed1

# Islandora based Drupal install.
RUN --mount=type=cache,id=demo-composer,sharing=locked,target=/root/.composer/cache \
    --mount=type=cache,id=demo-downloads,sharing=locked,target=/opt/downloads \
    # Get the Drupal codebase
    git-clone-cached.sh \
        --url https://github.com/dannylamb/islandora-sandbox.git \
        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
        --commit "${COMMIT}" \
        --worktree /var/www/drupal && \
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
    # Views Slideshow Dependencies
    ## jquery.cycle 
    JQUERY_CYCLE_FILE="jquery.cycle.all.js" && \
    JQUERY_CYCLE_URL="https://malsup.github.io/${JQUERY_CYCLE_FILE}" && \
    JQUERY_CYCLE_SHA256="58b44d975e1e1f0664d0fb8ab5b2918d08e9497324a021aa93de5894cdb586d4" && \
    mkdir -p /var/www/drupal/web/libraries/jquery.cycle && \
    download.sh --url "${JQUERY_CYCLE_URL}" --sha256 "${JQUERY_CYCLE_SHA256}" /var/www/drupal/web/libraries/jquery.cycle && \
    ## jquery.hoverIntent
    JQUERY_HOVER_INTENT_FILE="jquery.hoverIntent.js" && \
    JQUERY_HOVER_INTENT_URL="https://raw.githubusercontent.com/briancherne/jquery-hoverIntent/master/${JQUERY_HOVER_INTENT_FILE}" && \
    JQUERY_HOVER_INTENT_SHA256="65f5f7e1298fe71f10290f4068df30b38a5df0106d6feb63210ddabcc67c3e59" && \
    download.sh --url "${JQUERY_HOVER_INTENT_URL}" --sha256 "${JQUERY_HOVER_INTENT_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    mkdir -p /var/www/drupal/web/libraries/jquery.hoverIntent && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${JQUERY_HOVER_INTENT_FILE}" /var/www/drupal/web/libraries/jquery.hoverIntent && \
    ## jquery.pause
    JQUERY_PAUSE_FILE="jquery.pause.js" && \
    JQUERY_PAUSE_URL="https://raw.githubusercontent.com/tobia/Pause/master/${JQUERY_PAUSE_FILE}" && \
    JQUERY_PAUSE_SHA256="39505a2a9fe36fce5b987f6804723d323ac86d0ed7220a5c12094f1d698fce33" && \
    download.sh --url "${JQUERY_PAUSE_URL}" --sha256 "${JQUERY_PAUSE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    mkdir -p /var/www/drupal/web/libraries/jquery.pause && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${JQUERY_PAUSE_FILE}" /var/www/drupal/web/libraries/jquery.pause && \
    ## json2
    JSON2_FILE="jquery.pause.js" && \
    JSON2_URL="https://raw.githubusercontent.com/tobia/Pause/master/${JSON2_FILE}" && \
    JSON2_SHA256="39505a2a9fe36fce5b987f6804723d323ac86d0ed7220a5c12094f1d698fce33" && \
    download.sh --url "${JSON2_URL}" --sha256 "${JSON2_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    mkdir -p /var/www/drupal/web/libraries/json2 && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${JSON2_FILE}" /var/www/drupal/web/libraries/json2 && \
    # Openseadragon
    mkdir -p /var/www/drupal/web/sites/default/files/library-definitions && \
    cp /var/www/drupal/web/modules/contrib/openseadragon/openseadragon.json /var/www/drupal/web/sites/default/files/library-definitions

FROM ${repository}/drupal:${tag}

COPY --from=composer --chown=nginx:nginx /var/www /var/www
