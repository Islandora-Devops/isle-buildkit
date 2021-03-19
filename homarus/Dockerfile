# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/crayfish:${tag} AS crayfish

RUN --mount=type=cache,id=homarus-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Homarus && \
    ln -s /var/www/crayfish/Homarus/src /var/www/html

FROM alpine:3.13.2 AS cache
FROM ${repository}/nginx:${tag}

EXPOSE 8000

RUN --mount=type=cache,id=homarus-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add ffmpeg && \
    addgroup nginx jwt && \
    cleanup.sh

ENV HOMARUS_LOG_LEVEL=debug

COPY --from=crayfish /etc/nginx/http.d/default.conf /etc/nginx/http.d/default.conf
COPY --from=crayfish --chown=nginx:nginx /var/www /var/www

COPY rootfs /

WORKDIR /var/www/crayfish/Homarus/
