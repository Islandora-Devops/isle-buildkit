# syntax=docker/dockerfile:1.5.1
FROM crayfish

ARG TARGETARCH

EXPOSE 8000

WORKDIR /var/www/crayfish/Recast/

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=recast-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Recast && \
    ln -s /var/www/crayfish/Recast/public /var/www/html && \
    cleanup.sh

ENV \
    RECAST_DRUPAL_URL=islandora.traefik.me \
    RECAST_FCREPO_URL=islandora.traefik.me:8081/fcrepo/rest \
    RECAST_LOG_LEVEL=info

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
