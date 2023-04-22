#!/command/with-contenv bash
# shellcheck shell=bash
set -e

# UID should only be set in the development environments.
if [[ "${DEVELOPMENT_ENVIRONMENT}" == "true" ]]; then
  if [[ -n "${UID}" ]]; then
    if ! getent passwd ${UID}; then
      usermod -u ${UID} nginx
    fi
    if [[ "$(stat -c %u /var/www/drupal)" != "${UID}" ]]; then
      chown -R nginx:nginx /var/www
    fi
  fi
fi
