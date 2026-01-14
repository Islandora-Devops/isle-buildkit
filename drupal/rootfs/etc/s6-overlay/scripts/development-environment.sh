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

# Get the current user for this UID (if any) - don't fail if not found
EXISTING_USER=$(getent passwd "${UID}" 2>/dev/null | cut -d: -f1 || true)

if [ -z "$EXISTING_USER" ]; then
  # UID doesn't exist, safe to change nginx user
  usermod -u "${UID}" nginx
elif [ "$EXISTING_USER" != "nginx" ]; then
  # UID exists but belongs to another user
  # Move existing user out of the way
  NEW_UID=$((UID + 10000))
  usermod -u "${NEW_UID}" "$EXISTING_USER" || true
  usermod -u "${UID}" nginx
fi

# Fix ownership if needed
if [[ "$(stat -c %u /var/www/drupal)" != "${UID}" ]]; then
  chown -R nginx:nginx /var/www/drupal
fi

# Always ensure nginx has access to the socket
chown -R nginx:nginx /run/php-fpm83
