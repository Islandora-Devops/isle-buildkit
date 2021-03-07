# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/crayfish:${tag} AS download

RUN --mount=type=cache,id=houdini-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Houdini && \
    php /var/www/crayfish/Houdini/bin/console cache:clear && \
    ln -s /var/www/crayfish/Houdini/public /var/www/html && \
    chown -R nginx:nginx /var/www

FROM ${repository}/imagemagick:${tag} AS imagemagick
FROM ${repository}/crayfish:${tag}

RUN --mount=type=bind,from=imagemagick,source=/packages,target=/packages \
    --mount=type=bind,from=imagemagick,source=/etc/apk/keys,target=/etc/apk/keys \
    apk add /packages/imagemagick-*.apk && \
    cleanup.sh

COPY --from=download /var/www /var/www

ENV \
    HOUDINI_LOG_LEVEL=debug

COPY rootfs /

WORKDIR /var/www/crayfish/Houdini/
