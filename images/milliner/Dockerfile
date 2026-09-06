# syntax=docker/dockerfile:1.20.0
FROM nginx

ARG TARGETARCH

# renovate: datasource=github-releases depName=crayfish packageName=islandora/crayfish
ARG CRAYFISH_VERSION=5.0.2
ARG CRAYFISH_URL=https://github.com/Islandora/Crayfish/archive/refs/tags/${CRAYFISH_VERSION}.tar.gz
ARG CRAYFISH_SHA256="747fa78beb3485cf84015b65fe57fd3587a4203cea366b68d9f1b76c6346185a"

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
