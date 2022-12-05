# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/crayfish:${tag} AS crayfish

RUN --mount=type=cache,id=recast-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Recast && \
    ln -s /var/www/crayfish/Recast/public /var/www/html

FROM ${repository}/nginx:${tag}

EXPOSE 8000

ENV \
    RECAST_DRUPAL_URL=islandora.traefik.me \
    RECAST_FCREPO_URL=islandora.traefik.me:8081/fcrepo/rest \
    RECAST_LOG_LEVEL=info

WORKDIR /var/www/crayfish/Recast/

COPY --link --from=crayfish /etc/nginx/http.d/default.conf /etc/nginx/http.d/default.conf
COPY --link --from=crayfish /var/www /var/www

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
