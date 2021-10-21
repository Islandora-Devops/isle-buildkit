# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/crayfish:${tag} AS crayfish

RUN --mount=type=cache,id=recast-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Recast && \
    ln -s /var/www/crayfish/Recast/src /var/www/html

FROM ${repository}/nginx:${tag}

EXPOSE 8000

ENV \
    RECAST_DRUPAL_URL=islandora.traefik.me \
    RECAST_FCREPO_URL=islandora.traefik.me:8081/fcrepo/rest \
    RECAST_LOG_LEVEL=debug

COPY --from=crayfish /etc/confd /etc/confd
COPY --from=crayfish --chown=nginx:nginx /var/www /var/www

COPY rootfs /

WORKDIR /var/www/crayfish/Recast/
