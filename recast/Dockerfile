# syntax=docker/dockerfile:1.2.1
FROM local/crayfish:latest

RUN --mount=type=cache,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Recast && \
    ln -s /var/www/crayfish/Recast/src /var/www/html && \
    cleanup.sh

ENV \
    RECAST_DRUPAL_URL=drupal:80 \
    RECAST_FCREPO_URL=fcrepo/fcrepo/rest \
    RECAST_GEMINI_URL=gemini:8000 \
    RECAST_LOG_LEVEL=debug

COPY /rootfs /

RUN chown -R nginx:nginx /var/www

WORKDIR /var/www/crayfish/Recast/
