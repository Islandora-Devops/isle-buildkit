# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/crayfish:${tag} AS download

RUN --mount=type=cache,id=homarus-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Homarus && \
    ln -s /var/www/crayfish/Homarus/src /var/www/html && \
    chown -R nginx:nginx /var/www

FROM alpine:3.13.2 AS cache
FROM ${repository}/crayfish:${tag}

COPY --from=download /var/www /var/www

RUN --mount=type=cache,id=homarus-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add \
        ffmpeg \
    && \
    cleanup.sh

ENV \
    HOMARUS_LOG_LEVEL=debug

COPY rootfs /

WORKDIR /var/www/crayfish/Homarus/
