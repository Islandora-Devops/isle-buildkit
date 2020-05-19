# syntax=docker/dockerfile:experimental
FROM islandora/drupal:latest

# Islandora based Drupal install.
RUN --mount=type=cache,target=/root/.composer/cache \
    --mount=id=downloads,type=cache,target=/opt/downloads \
    php -d memory_limit=-1 /usr/bin/composer create-project islandora/drupal-project:8.8.1 \
        --prefer-dist \
        --no-interaction \
        --stability stable \
        --no-dev \
        --no-install \
        /var/www/drupal \
    && \
    php -d memory_limit=-1 /usr/bin/composer require --update-no-dev -- drush/drush:^9.7.1 && \
    wget -N -P /opt/downloads https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar && \
    cp /opt/downloads/drush.phar /usr/local/bin/drush && \
    chmod a+x /usr/local/bin/drush && \
    mkdir /var/www/drupal/config && \
    mkdir -p /var/www/drupal/web/libraries && \
    chown -R nginx:nginx /var/www && \
    php -d memory_limit=-1 /usr/bin/composer require --update-no-dev -- \
        zaporylie/composer-drupal-optimizations:^1.0 \
        drupal/console:~1.0 \
        drupal/devel:^2.0 \
        drush/drush:^9.0 \
        drupal/rdfui:^1.0-beta1 \
        drupal/restui:^1.16 \
        drupal/search_api_solr:^3.8 \
        drupal/facets:^1.3 \
        drupal/content_browser:^1.0@alpha \
        drupal/matomo:^1.7 \
        drupal/pdf:1.x-dev \
        drupal/admin_toolbar:^2.0 \
        drupal/rest_oai_pmh:^1.0 \
        drupal/transliterate_filenames:^1.3 \
        islandora/carapace:dev-8.x-3.x \
        islandora/islandora_defaults:dev-8.x-1.x \
        islandora-rdm/islandora_fits:dev-master && \
    MASONRY_VERSION=3.3.2 && \
    wget -N -P /opt/downloads https://github.com/desandro/masonry/archive/v${MASONRY_VERSION}.zip && \
    unzip "/opt/downloads/v${MASONRY_VERSION}.zip" -d /var/www/drupal/web/libraries && \
    mv  /var/www/drupal/web/libraries/masonry-${MASONRY_VERSION} /var/www/drupal/web/libraries/masonry && \
    PDFJS_VERSION=2.0.943 && \
    wget -N -P /opt/downloads https://github.com/mozilla/pdf.js/releases/download/v${PDFJS_VERSION}/pdfjs-${PDFJS_VERSION}-dist.zip && \
    mkdir -p /var/www/drupal/web/libraries/pdfjs.js && \
    unzip "/opt/downloads/pdfjs-${PDFJS_VERSION}-dist.zip" -d /var/www/drupal/web/libraries/pdfjs.js && \
    cleanup.sh

VOLUME [ "/opt/keys/claw", "/var/www/drupal/config", "/var/www/drupal/web/sites" ]

COPY rootfs /
