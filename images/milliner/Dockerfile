# syntax=docker/dockerfile:1.20.0
FROM nginx

ARG TARGETARCH

# renovate: datasource=github-releases depName=crayfish packageName=islandora/crayfish
ARG CRAYFISH_VERSION=5.0.1
ARG CRAYFISH_URL=https://github.com/Islandora/Crayfish/archive/refs/tags/${CRAYFISH_VERSION}.tar.gz
ARG CRAYFISH_SHA256=449e6a74fb4a12e881fe1ab8477ca1c1b4c2677004b6185a6bad02d4b1017678

RUN --mount=type=cache,id=milliner-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${CRAYFISH_URL}" \
        --sha256 "${CRAYFISH_SHA256}" \
        --strip \
        --dest /var/www/crayfish && \
    cleanup.sh

EXPOSE 8000

WORKDIR /var/www/crayfish/Milliner/

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=milliner-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    composer install \
        --working-dir=/var/www/crayfish/Milliner \
        --no-dev \
        --no-interaction \
        --no-progress \
        --prefer-dist \
        --classmap-authoritative && \
    ln -s /var/www/crayfish/Milliner/public /var/www/html && \
    cleanup.sh

ENV \
    MILLINER_FCREPO_URL=http://fcrepo:8080/fcrepo/rest \
    MILLINER_FEDORA6=true \
    MILLINER_LOG_LEVEL=info

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
