# syntax=docker/dockerfile:1.2.1
FROM local/crayfish:latest

RUN --mount=type=cache,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Recast && \
    ln -s /var/www/crayfish/Recast/src /var/www/html && \
    cleanup.sh

ENV \
    RECAST_DRUPAL_URL=islandora.traefik.me \
    RECAST_FCREPO_URL=islandora.traefik.me:8081/fcrepo/rest \
    RECAST_LOG_LEVEL=debug

COPY /rootfs /

RUN chown -R nginx:nginx /var/www

WORKDIR /var/www/crayfish/Recast/
