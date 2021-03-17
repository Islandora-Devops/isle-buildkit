#!/usr/bin/env bash
set -e

# Allow NGINX_ERROR_LOG_LEVEL to be overriden by DRUPAL_NGINX_ERROR_LOG_LEVEL, etc.
/usr/local/bin/confd-override-environment.sh --prefix TOMCAT
