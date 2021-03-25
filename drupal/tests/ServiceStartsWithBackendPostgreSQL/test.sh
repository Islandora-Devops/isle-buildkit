#!/usr/bin/with-contenv bash

source /usr/local/share/isle/utilities.sh

# Install basic Drupal
rm -fr /var/www/drupal/*
composer create-project drupal/recommended-project:^9.1 \
        --prefer-dist \
        --no-interaction \
        --stability stable \
        --no-dev \
        -- /var/www/drupal

# Install Drush.
(cd /var/www/drupal && composer require drush/drush:^10.0)

# Install actual site.
source /etc/islandora/utilities.sh
mkdir -p /var/www/drupal/web/sites/default/files
chown -R nginx:nginx /var/www/drupal
create_database "DEFAULT"
install_site "DEFAULT"

# Exit non-zero if database does not exist.
PGPASSWORD="${DB_ROOT_PASSWORD}" psql \
        --host="${DB_HOST}" \
        --port="${DB_PORT}" \
        --username="${DB_ROOT_USER}" \
        --dbname="drupal_default" \
        -c "\q"

# Wait for Drupal to start.
wait_20x http://localhost:80/user

# All tests were successful
exit 0