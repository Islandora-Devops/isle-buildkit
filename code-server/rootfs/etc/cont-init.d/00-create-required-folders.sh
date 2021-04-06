#!/usr/bin/env bash
set -e

# Needed to render templates
mkdir -p /var/www/drupal/.vscode
chown nginx:nginx /var/www/drupal/.vscode

mkdir -p /var/www/drupal/web/sites/default
chown nginx:nginx /var/www/drupal/web/sites/default