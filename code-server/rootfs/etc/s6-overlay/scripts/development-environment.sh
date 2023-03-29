#!/command/with-contenv bash
# shellcheck shell=bash
set -e

if [[ "${DEVELOPMENT_ENVIRONMENT}" == "true" ]]; then
  if [[ -n "${UID}" ]]; then
    if ! getent passwd ${UID}; then
      usermod -u ${UID} nginx
      parallel --will-cite chown -R nginx:nginx ::: \
        /opt/code-server \
        /root/.composer \
        /var/lib/nginx \
        /var/www
    fi
  fi
fi
