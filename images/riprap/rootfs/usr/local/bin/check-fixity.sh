#!/usr/bin/env bash

set -e

# Ensures check_fixity runs as the correct user from the correct directory, and
# does not run out of memory.
(
    cd /var/www/riprap
    if test "$(id -u)" -eq 0; then
        # If root run as nginx.
        s6-setuidgid nginx php -d memory_limit=-1 /var/www/riprap/bin/console app:riprap:check_fixity "${@}"
    else
        # If non-root user, then run as current user
        # as we do not have permissions to switch user.
        php -d memory_limit=-1 /var/www/riprap/bin/console app:riprap:check_fixity "${@}"
    fi
)
