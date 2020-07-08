#!/usr/bin/with-contenv bash
set -e

# Runs before templates are rendered (before 01-confd-render-templates.sh).
# Copies matomo into the expected location it will run from (/var/www/matomo),
# if not already present. This is to allow users to use non-volume mounts like
# bind (https://docs.docker.com/storage/volumes/) for the entire matomo install.
if [[ ! -d /var/www/matomo/config ]]; then
    cp -r /opt/matomo /var/www
    chown nginx:nginx -R /var/www/matomo
fi
