# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/crayfish:${tag} AS download

RUN --mount=type=cache,id=recast-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Recast && \
    ln -s /var/www/crayfish/Recast/src /var/www/html && \
    chown -R nginx:nginx /var/www

FROM ${repository}/crayfish:${tag}

COPY --from=download /var/www /var/www

ENV \
    RECAST_DRUPAL_URL=drupal:80 \
    RECAST_FCREPO_URL=fcrepo/fcrepo/rest \
    RECAST_GEMINI_URL=gemini:8000 \
    RECAST_LOG_LEVEL=debug

COPY rootfs /

WORKDIR /var/www/crayfish/Recast/
