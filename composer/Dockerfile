# syntax=docker/dockerfile:experimental
FROM local/nginx:latest as composer

# Overwrite with your own arguments or explicitly copy in 
# your own composer.json / composer.lock files instead.
# https://getcomposer.org/doc/03-cli.md#create-project
ARG composer_project="drupal/recommended-project"

WORKDIR /build

RUN --mount=type=cache,target=/root/.composer/cache \
    composer create-project --no-install ${composer_project} /build && \
    composer require -- drush/drush && \
    composer install

FROM local/drupal:latest

RUN --mount=type=bind,from=composer,source=/build,target=/build \
    cp -r /build/* /var/www/drupal && \
    chown -R nginx:nginx /var/www/drupal && \
    wget -N -P /opt/downloads https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar && \
    cp /opt/downloads/drush.phar /usr/local/bin/drush && \
    chmod a+x /usr/local/bin/drush && \
    cleanup.sh
