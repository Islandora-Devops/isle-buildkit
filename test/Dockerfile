# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/composer:${tag} AS composer

ARG COMMIT=2b6731680a77befa16c5d3d50ba690f502be401b

RUN --mount=type=cache,id=test-downloads,sharing=locked,target=/opt/downloads \
    git-clone-cached.sh \
        --url https://github.com/Islandora/islandora-starter-site.git \
        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
        --commit "${COMMIT}" \
        --worktree /var/www/drupal

COPY --link rootfs/var/www/drupal /var/www/drupal

RUN --mount=type=cache,id=test-drupal-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/drupal

FROM ${repository}/drupal:${tag}

# jq used by install script to parse the output of ActiveMQ checks.
RUN apk add jq

COPY --link --from=composer /var/www/drupal /var/www/drupal

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
