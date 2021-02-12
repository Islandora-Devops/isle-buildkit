# syntax=docker/dockerfile:1.2.1
FROM local/nginx:latest

ARG COMMIT=6e95f2f325c910b254a2b7bd1cedf25b17874d30

RUN --mount=type=cache,target=/root/.composer/cache \
    --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    git-clone-cached.sh \
        --url https://github.com/roblib/CrayFits.git \
        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
        --commit "${COMMIT}" \
        --worktree /var/www/crayfits && \
    composer install -d /var/www/crayfits && \
    mkdir /var/log/islandora && \
    chown nginx:nginx /var/log/islandora && \
    chown -R nginx:nginx /var/www && \
    cleanup.sh

WORKDIR /var/www/crayfits

STOPSIGNAL SIGWINCH

EXPOSE 8000

ENV \
    CRAYFITS_LOG_LEVEL=debug \
    CRAYFITS_WEBSERVICE_URI=fits/fits/examine

COPY /rootfs /