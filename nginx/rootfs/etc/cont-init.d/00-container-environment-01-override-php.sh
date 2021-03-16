#!/usr/bin/env bash
set -e

# Allow PHP_LOG_LEVEL to be overriden by DRUPAL_PHP_LOG_LEVEL, etc.
/usr/local/bin/confd-override-environment.sh --prefix PHP
