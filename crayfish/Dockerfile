# syntax=docker/dockerfile:1.2.1
FROM local/nginx:latest

ARG COMMIT=ae9a35c88d2bdfd0343122a8b5b373d6368cc623

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    git-clone-cached.sh \
        --url https://github.com/Islandora/Crayfish.git \
        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
        --commit "${COMMIT}" \
        --worktree /var/www/crayfish && \
    addgroup nginx jwt && \
    mkdir /var/log/islandora && \
    chown nginx:nginx /var/log/islandora && \
    chown -R nginx:nginx /var/www && \
    cleanup.sh

COPY /rootfs /

EXPOSE 8000
