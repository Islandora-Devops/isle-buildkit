#!/usr/bin/env bash
set -e

mkdir /run/nginx &> /dev/null || true

# Change log files to redirect to stdout/stderr
ln -sf /dev/stdout /var/log/nginx/access.log
chown nginx:nginx /var/log/nginx/access.log

ln -sf /dev/stderr /var/log/nginx/error.log
chown nginx:nginx /var/log/nginx/error.log
