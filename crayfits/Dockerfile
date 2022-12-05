# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/composer:${tag} AS composer

# Use a lock file for reproducible builds, always update it when updating the commit above.
ARG COMMIT=4c3721173e8ded0cab4da673c9987ad6cb0548c9
COPY --link rootfs/var/www/crayfits/composer.lock /tmp/composer.lock

RUN --mount=type=cache,id=crayfits-downloads,sharing=locked,target=/opt/downloads \
    --mount=type=cache,id=crayfish-composer,sharing=locked,target=/root/.composer/cache \
    git-clone-cached.sh \
        --url https://github.com/nigelgbanks/CrayFits.git \
        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
        --commit "${COMMIT}" \
        --worktree /var/www/crayfits && \
    mv /tmp/composer.lock /var/www/crayfits/composer.lock && \
    composer install -d /var/www/crayfits

FROM ${repository}/nginx:${tag}

EXPOSE 8000

# Required at the moment as the log location is hard-coded in crayfits.
RUN mkdir -p /var/log/islandora && \
    touch /var/log/islandora/fits.log && \
    chown -R nginx:nginx /var/log/islandora && \
    cleanup.sh

ENV \
    CRAYFITS_LOG_LEVEL=info \
    CRAYFITS_WEBSERVICE_URI=fits:8080/fits/examine

WORKDIR /var/www/crayfits

COPY --link --from=composer /var/www /var/www

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
