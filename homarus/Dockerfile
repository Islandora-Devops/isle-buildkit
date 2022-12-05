# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.16.2
FROM --platform=$BUILDPLATFORM ${repository}/crayfish:${tag} AS crayfish

RUN --mount=type=cache,id=homarus-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Homarus && \
    ln -s /var/www/crayfish/Homarus/public /var/www/html

FROM alpine:${alpine} AS cache
FROM ${repository}/nginx:${tag}

EXPOSE 8000

RUN --mount=type=cache,id=homarus-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add ffmpeg && \
    addgroup nginx jwt && \
    cleanup.sh

ENV \
    HOMARUS_FCREPO_URL=http://fcrepo:8080/fcrepo/rest \
    HOMARUS_LOG_LEVEL=info

WORKDIR /var/www/crayfish/Homarus/

COPY --link --from=crayfish /etc/nginx/http.d/default.conf /etc/nginx/http.d/default.conf
COPY --link --from=crayfish /var/www /var/www

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
