# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/crayfish:${tag} AS download

RUN --mount=type=cache,id=milliner-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Milliner && \
    ln -s /var/www/crayfish/Milliner/src /var/www/html && \
    chown -R nginx:nginx /var/www

FROM ${repository}/crayfish:${tag}

COPY --from=download /var/www /var/www

ENV \
    MILLINER_DRUPAL_URL=http://drupal:80 \
    MILLINER_FCREPO_URL=http://fcrepo:8080/fcrepo/rest \
    MILLINER_GEMINI_URL=http://gemini:8000 \
    MILLINER_LOG_LEVEL=debug

COPY rootfs /

WORKDIR /var/www/crayfish/Milliner/
