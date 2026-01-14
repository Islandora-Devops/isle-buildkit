#!/command/with-contenv bash
# shellcheck shell=bash
set -e

# UID should only be set in the development environments.
if [[ "${DEVELOPMENT_ENVIRONMENT}" != "true" ]]; then
  exit 0
fi
if [[ -z "${UID}" ]]; then
  exit 0
fi

# Get the current user for this UID (if any)
EXISTING_USER=$(getent passwd ${UID} | cut -d: -f1)

if [ -z "$EXISTING_USER" ]; then
  # UID doesn't exist, safe to change nginx user
  usermod -u ${UID} nginx
elif [ "$EXISTING_USER" != "nginx" ]; then
  # UID exists but belongs to another user
  usermod -u $((UID + 10000)) "$EXISTING_USER"
  usermod -u ${UID} nginx
fi

if [[ "$(stat -c %u /var/www/drupal)" != "${UID}" ]]; then
  chown -R nginx:nginx /var/www/drupal
fi

# always ensure nginx has access to the socket
chown -R nginx:nginx /run/php-fpm83

