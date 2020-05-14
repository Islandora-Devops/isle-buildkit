# syntax=docker/dockerfile:experimental
FROM islandora/imagemagick:latest as imagemagick

FROM islandora/crayfish:latest

RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \ 
    --mount=type=bind,from=imagemagick,source=/home/builder/packages/x86_64,target=/packages \
    --mount=type=bind,from=imagemagick,source=/etc/apk/keys,target=/etc/apk/keys \
    --mount=id=composer,sharing=locked,type=cache,target=/root/.composer/cache \
    apk add /packages/imagemagick-*.apk && \
    composer install -d /var/www/crayfish/Houdini && \
    php /var/www/crayfish/Houdini/bin/console cache:clear && \
    ln -s /var/www/crayfish/Houdini/public /var/www/html && \
    cleanup.sh

COPY /rootfs /

RUN chown -R nginx:nginx /var/www

WORKDIR /var/www/crayfish/Houdini/
