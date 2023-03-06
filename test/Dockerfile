# syntax=docker/dockerfile:1.5.1
FROM drupal

ARG TARGETARCH
ARG COMMIT=2b6731680a77befa16c5d3d50ba690f502be401b
ARG FILE=${COMMIT}.tar.gz
ARG URL=https://github.com/Islandora/islandora-starter-site/archive/${FILE}
ARG SHA256=4c278ed0b89ab5c4818e5026b7bff9bb67b909247cbfc821743c2207da4cafd1

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=test-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${URL}" \
        --sha256 "${SHA256}" \
        --strip \
        --dest "/var/www/drupal" \
    && \
    cleanup.sh

RUN --mount=type=bind,source=rootfs/var/www/drupal/assets/patches/default_settings.txt,target=/var/www/drupal/assets/patches/default_settings.txt \
    --mount=type=cache,id=test-drupal-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/drupal && \
    cleanup.sh

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
