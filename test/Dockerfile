# syntax=docker/dockerfile:1.5.1
FROM drupal

ARG TARGETARCH
# renovate: datasource=git-refs depName=islandora-starter-site packageName=https://github.com/islandora-devops/islandora-starter-site branch=main
ARG COMMIT=9a2da0c416a5fe8a8ba78caf384357401ae31291
ARG FILE=${COMMIT}.tar.gz
ARG URL=https://github.com/Islandora/islandora-starter-site/archive/${FILE}
ARG SHA256="43c7350b2240e251bfa5bb87b4baaaa0addb460b66cf4e6f04cc7249ae91bcf0"

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=test-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${URL}" \
        --sha256 "${SHA256}" \
        --strip \
        --dest "/var/www/drupal" \
    && \
    cleanup.sh

# Import Default content, includes content normally included via migrate import.
# So that the links between the default content and the tags work correctly (linked by UUID rather than ID).
RUN --mount=type=bind,source=rootfs/var/www/drupal/assets/patches/default_settings.txt,target=/var/www/drupal/assets/patches/default_settings.txt \
    --mount=type=bind,source=rootfs/var/www/drupal/web/modules/custom,target=/var/www/drupal/web/modules/custom \
    --mount=type=cache,id=test-drupal-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    composer -d /var/www/drupal config minimum-stability dev && \
    composer -d /var/www/drupal config repositories.sample_core path ./web/modules/custom/sample_core && \
    composer -d /var/www/drupal require 'islandora/sample_core:*' && \
    composer install -d /var/www/drupal && \
    cleanup.sh

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
