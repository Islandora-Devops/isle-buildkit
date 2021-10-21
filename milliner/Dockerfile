# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/crayfish:${tag} AS crayfish

RUN --mount=type=cache,id=milliner-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Milliner && \
    ln -s /var/www/crayfish/Milliner/src /var/www/html

FROM ${repository}/nginx:${tag}

EXPOSE 8000

ENV \
    MILLINER_DRUPAL_URL=http://drupal:80 \
    MILLINER_FCREPO_URL=http://fcrepo:8080/fcrepo/rest \
    MILLINER_FEDORA6=false \
    MILLINER_LOG_LEVEL=debug

COPY --from=crayfish /etc/confd /etc/confd
COPY --from=crayfish --chown=nginx:nginx /var/www /var/www

COPY rootfs /

WORKDIR /var/www/crayfish/Milliner/
