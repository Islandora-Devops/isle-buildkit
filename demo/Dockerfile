# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/composer:${tag} AS composer

ARG COMMIT=67b8e87ddd5c5b5a01522aaf3129ad4c661cb76d

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
    composer install

FROM ${repository}/drupal:${tag}

COPY --from=composer --chown=nginx:nginx /var/www /var/www
