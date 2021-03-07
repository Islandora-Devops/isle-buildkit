# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/nginx:${tag} AS download

ARG COMMIT=6e95f2f325c910b254a2b7bd1cedf25b17874d30

RUN --mount=type=cache,id=crayfish-composer,sharing=locked,target=/root/.composer/cache \
    --mount=type=cache,id=crayfits-downloads,sharing=locked,target=/opt/downloads \
    git-clone-cached.sh \
        --url https://github.com/roblib/CrayFits.git \
        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
        --commit "${COMMIT}" \
        --worktree /var/www/crayfits && \
    composer install -d /var/www/crayfits && \
    chown -R nginx:nginx /var/www

FROM ${repository}/nginx:${tag}

COPY --from=download /var/www /var/www

# Required at the moment as the log location is hard-coded in crayfits.
RUN mkdir -p /var/log/islandora && \
    touch /var/log/islandora/fits.log && \
    chown -R nginx:nginx /var/log/islandora && \
    cleanup.sh

WORKDIR /var/www/crayfits

STOPSIGNAL SIGWINCH

EXPOSE 8000

ENV \
    CRAYFITS_LOG_LEVEL=debug \
    CRAYFITS_WEBSERVICE_URI=fits/fits/examine

COPY rootfs /