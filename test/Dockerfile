# syntax=docker/dockerfile:1.5.1
FROM drupal

ARG TARGETARCH
# renovate: datasource=git-refs depName=islandora-starter-site packageName=https://github.com/islandora-devops/islandora-starter-site branch=main
ARG COMMIT=c090310cf05dd7d293aa2b107a80db5d418149df
ARG FILE=${COMMIT}.tar.gz
ARG URL=https://github.com/Islandora/islandora-starter-site/archive/${FILE}
ARG SHA256="7969a30af6e2303cfe430fbdb710f18721d6141328a5c1d26b048077960e63d0"

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
