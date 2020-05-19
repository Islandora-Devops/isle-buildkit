# syntax=docker/dockerfile:experimental
FROM islandora/nginx:latest

ARG COMMIT=4e0faeb31f84e74e7cecc083b2f096d55e425fbb

RUN --mount=type=cache,target=/root/.composer/cache \
    --mount=id=downloads,type=cache,target=/opt/downloads \
    git-clone-cached.sh \
        --url https://github.com/roblib/CrayFits.git \
        --commit "${COMMIT}" \
        --worktree /var/www/crayfits && \
    composer install -d /var/www/crayfits && \
    mkdir /var/log/islandora && \
    chown nginx:nginx /var/log/islandora && \
    chown -R nginx:nginx /var/www && \
    cleanup.sh

COPY /rootfs /

STOPSIGNAL SIGWINCH

EXPOSE 8000
