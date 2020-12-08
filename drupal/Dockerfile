# syntax=docker/dockerfile:experimental
FROM local/nginx:latest

RUN --mount=type=cache,target=/var/cache/apk \
    apk-install.sh \
      patch && \
    cleanup.sh

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    DRUSH_VERSION="0.6.0" && \
    DRUSH_FILE="drush.phar" && \
    DRUSH_URL="https://github.com/drush-ops/drush-launcher/releases/download/${DRUSH_VERSION}/${DRUSH_FILE}" && \
    DRUSH_SHA256="c3f32a800a2f18470b0010cd71c49e49ef5c087f8131eecfe9b686dc1f3f3d4e" && \
    download.sh --url "${DRUSH_URL}" --sha256 "${DRUSH_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${DRUSH_FILE}" /usr/bin/drush && \
    chmod a+x /usr/bin/drush && \
    mkdir -p /var/www/drupal/config && \
    mkdir -p /var/www/drupal/web/libraries && \
    chown -R nginx:nginx /var/www && \
    mkdir -p /opt/keys/jwt && \
    chown nginx:nginx /opt/keys/jwt

WORKDIR /var/www/drupal

EXPOSE 80

ENV \
    DRUPAL_DEFAULT_ACCOUNT_EMAIL=webmaster@localhost.com \
    DRUPAL_DEFAULT_ACCOUNT_NAME=admin \
    DRUPAL_DEFAULT_ACCOUNT_PASSWORD=password \
    DRUPAL_DEFAULT_BROKER_HOST=activemq \
    DRUPAL_DEFAULT_BROKER_PORT=61613 \
    DRUPAL_DEFAULT_CANTALOUPE_URL=https://islandora.traefik.me/cantaloupe/iiif/2 \
    DRUPAL_DEFAULT_CONFIGDIR=/var/www/drupal/config/sync \
    DRUPAL_DEFAULT_DB_DRIVER=mysql \
    DRUPAL_DEFAULT_DB_HOST=mariadb \
    DRUPAL_DEFAULT_DB_NAME=drupal_default \
    DRUPAL_DEFAULT_DB_PASSWORD=password \
    DRUPAL_DEFAULT_DB_PORT=3306 \
    DRUPAL_DEFAULT_DB_ROOT_PASSWORD=password \
    DRUPAL_DEFAULT_DB_ROOT_USER=root \
    DRUPAL_DEFAULT_DB_USER=drupal_default \
    DRUPAL_DEFAULT_EMAIL=webmaster@localhost.com \
    DRUPAL_DEFAULT_FCREPO_HOST=islandora.traefik.me \
    DRUPAL_DEFAULT_FCREPO_PORT=8081 \
    DRUPAL_DEFAULT_GEMINI_HOST=gemini \
    DRUPAL_DEFAULT_GEMINI_PORT=8000 \
    DRUPAL_DEFAULT_INSTALL=true \
    DRUPAL_DEFAULT_INSTALL_EXISTING_CONFIG=false \
    DRUPAL_DEFAULT_LOCALE=en \
    DRUPAL_DEFAULT_MATOMO_URL=https://islandora.traefik.me/matomo/ \
    DRUPAL_DEFAULT_NAME=Default \
    DRUPAL_DEFAULT_PROFILE=standard \
    DRUPAL_DEFAULT_SALT=9PPaL0CxZAIcq0l9wxgDGlCZrp7JdT_x7v9gVzpdbUjMt1PqDz3uD0Zy-i16DuJ1-Htuq5hqeg \
    DRUPAL_DEFAULT_SITE_URL=https://islandora.traefik.me \
    DRUPAL_DEFAULT_SOLR_CORE=ISLANDORA \
    DRUPAL_DEFAULT_SOLR_HOST=solr \
    DRUPAL_DEFAULT_SOLR_PORT=8983 \
    DRUPAL_DEFAULT_SUBDIR=default \
    DRUPAL_DEFAULT_TRIPLESTORE_HOST=blazegraph \
    DRUPAL_DEFAULT_TRIPLESTORE_NAMESPACE=islandora \
    DRUPAL_DEFAULT_TRIPLESTORE_PORT=80 \
    DRUPAL_SITES=DEFAULT

COPY rootfs /
