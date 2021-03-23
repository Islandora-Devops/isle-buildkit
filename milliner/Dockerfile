# syntax=docker/dockerfile:1.2.1
FROM local/crayfish:latest

RUN --mount=type=cache,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Milliner && \
    ln -s /var/www/crayfish/Milliner/src /var/www/html && \
    cleanup.sh

ENV \
    MILLINER_DRUPAL_URL=http://drupal:80 \
    MILLINER_FCREPO_URL=http://fcrepo:8080/fcrepo/rest \
    MILLINER_FEDORA6=false \
    MILLINER_LOG_LEVEL=debug

COPY /rootfs /

RUN chown -R nginx:nginx /var/www

WORKDIR /var/www/crayfish/Milliner/
