# syntax=docker/dockerfile:1.5.1
FROM drupal

ARG TARGETARCH
ARG COMMIT=0.5.2
ARG FILE=${COMMIT}.tar.gz
ARG URL=https://github.com/Islandora/islandora-starter-site/archive/${FILE}
ARG SHA256=456cdae4240d8cdebe4da7eee5820acf0d8c023a94e85be06acdf20dd04ded82

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
