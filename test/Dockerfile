# syntax=docker/dockerfile:1.5.1
FROM drupal

ARG TARGETARCH
# renovate: datasource=git-refs depName=islandora-starter-site packageName=https://github.com/islandora-devops/islandora-starter-site branch=main
ARG COMMIT=35c632485a65bbd2f5412b640b7e437294f39b20
ARG FILE=${COMMIT}.tar.gz
ARG URL=https://github.com/Islandora/islandora-starter-site/archive/${FILE}
ARG SHA256="6a5482a4b935fc527119c57b8cba69983bedd1b6dee0d5228550128e1ad1d07a"

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
