# syntax=docker/dockerfile:1.5.1
FROM nginx

# Use a lock file for reproducible builds, always update it when updating the commit above.
ARG TARGETARCH
ARG CRAYFITS_COMMIT=89f8229508c3da4f3d4a7002eb72a69c40c03e94
ARG CRAYFITS_FILE=${CRAYFITS_COMMIT}.tar.gz
ARG CRAYFITS_URL=https://github.com/roblib/CrayFits/archive/${CRAYFITS_FILE}
ARG CRAYFITS_SHA256=f6c45699d2dbf28c984777abb7a18bb3e864d27666abb71488e2ffbcc567632a

EXPOSE 8000

WORKDIR /var/www/crayfits

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=crayfits-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    --mount=type=cache,id=crayfish-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    download.sh \
        --url "${CRAYFITS_URL}" \
        --sha256 "${CRAYFITS_SHA256}" \
        --strip \
        --dest "/var/www/crayfits" \
    && \
    cleanup.sh

# Required at the moment as the log location is hard-coded in crayfits.
RUN mkdir -p /var/log/islandora && \
    touch /var/log/islandora/fits.log && \
    chown -R nginx:nginx /var/log/islandora && \
    cleanup.sh

RUN --mount=type=bind,source=rootfs/var/www/crayfits/composer.lock,target=/var/www/crayfits/composer.lock \
    composer install -d /var/www/crayfits && \
    cleanup.sh

ENV \
    CRAYFITS_LOG_LEVEL=info \
    CRAYFITS_WEBSERVICE_URI=fits:8080/fits/examine

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
