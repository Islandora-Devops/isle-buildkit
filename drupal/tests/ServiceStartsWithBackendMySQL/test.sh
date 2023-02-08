#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# Install basic Drupal
cd /var/www/drupal || exit 1
rm -fr /var/www/drupal/*
composer create-project drupal/recommended-project:^9.4 \
    --prefer-dist \
    --no-interaction \
    --stability stable \
    --no-dev \
    -- /var/www/drupal

# Install Drush.
composer require drush/drush:^11.0

# Install actual site.
# shellcheck disable=SC1091
source /etc/islandora/utilities.sh
mkdir -p /var/www/drupal/web/sites/default/files
chown -R nginx:nginx /var/www/drupal
create_database "DEFAULT"
install_site "DEFAULT"

# Exit non-zero if database does not exist.
cat <<-EOF | execute-sql-file.sh
	use ${DB_NAME}
EOF

# Wait for Drupal to start.
wait_20x http://localhost:80/user

# All tests were successful
exit 0
