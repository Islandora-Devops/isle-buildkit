#!/usr/bin/env bash
set -e

mkdir /run/php-fpm7 &> /dev/null || true

# Change log files to redirect to stdout/stderr
ln -sf /dev/stderr /var/log/php7/error.log
chown nginx:nginx /var/log/php7/error.log
