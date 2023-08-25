#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# Install basic Drupal
cd /var/www/drupal || exit 1
rm -fr /var/www/drupal/*
composer create-project drupal/recommended-project:^10.1.2 \
    --prefer-dist \
    --no-interaction \
    --stability stable \
    --no-dev \
    -- /var/www/drupal

# Install Drush.
composer require drush/drush:^12.1.3

# Install actual site.
# shellcheck disable=SC1091
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
