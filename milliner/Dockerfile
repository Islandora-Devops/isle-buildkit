# syntax=docker/dockerfile:experimental
FROM islandora/crayfish:latest

RUN --mount=type=cache,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Milliner && \
    ln -s /var/www/crayfish/Milliner/src /var/www/html && \
    cleanup.sh

COPY /rootfs /

RUN chown -R nginx:nginx /var/www

WORKDIR /var/www/crayfish/Milliner/
