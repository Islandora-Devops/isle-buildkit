#!/usr/bin/with-contenv bash

source /usr/local/share/isle/utilities.sh

# Checks that all `DB` environment variables can be overriden.
expect "DB_DRIVER" "postgresql"
expect "DB_MYSQL_HOST" "DB_MYSQL_HOST override"
expect "DB_MYSQL_PORT" "DB_MYSQL_PORT override"
expect "DB_NAME" "DB_NAME override"
expect "DB_PASSWORD" "DB_PASSWORD override"
expect "DB_POSTGRESQL_HOST" "DB_POSTGRESQL_HOST override"
expect "DB_POSTGRESQL_PORT" "DB_POSTGRESQL_PORT override"
expect "DB_ROOT_PASSWORD" "DB_ROOT_PASSWORD override"
expect "DB_ROOT_USER" "DB_ROOT_USER override"
expect "DB_USER" "DB_USER override"

# All tests were successful
exit 0
