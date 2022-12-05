#!/usr/bin/env bash
set -e

# Needed to render templates. Must be done at runtime as it could be a volume.
mkdir -p /var/www/drupal/.vscode
chown nginx:nginx /var/www/drupal/.vscode

mkdir -p /var/www/drupal/web/sites/default
chown nginx:nginx /var/www/drupal/web/sites/default
