# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/composer:${tag} AS composer

ARG MATOMO_VERSION="4.12.3"
ARG MATOMO_FILE_SHA256="00efe4335c9cee9f269b5e8a337026af7f115c05cde1e9ae47485592372b37ee"

# When updating this commit also update the lock files in rootfs/var/www/crayfish.
ARG MATOMO_COMMIT=4.10.1
ARG EXTRA_TOOLS_COMMIT=4.0.1-beta4

RUN --mount=type=cache,id=matomo-downloads,sharing=locked,target=/opt/downloads \
    git-clone-cached.sh \
        --url https://github.com/matomo-org/matomo.git \
        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
        --commit "${EXTRA_TOOLS_COMMIT}" \
        --worktree /opt/matomo && \
    composer require -d /opt/matomo symfony/yaml:~2.6.0 && \
    composer require -d /opt/matomo symfony/process:^3.4 && \
    composer install -d /opt/matomo && \
    git-clone-cached.sh \
        --url https://github.com/digitalist-se/extratools.git \
        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
        --commit "${EXTRA_TOOLS_COMMIT}" \
        --worktree /opt/matomo/plugins/ExtraTools

# @todo Nigel should you revert this it would build faster but you need to deal with the composer things...
#RUN --mount=type=cache,id=matomo-downloads,sharing=locked,target=/opt/downloads \
#    MATOMO_FILE="matomo-${MATOMO_VERSION}.tar.gz" && \
#    MATOMO_URL="https://builds.matomo.org/${MATOMO_FILE}" && \
#    download.sh --url "${MATOMO_URL}" --sha256 "${MATOMO_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
#    tar -xzf "${DOWNLOAD_CACHE_DIRECTORY}/${MATOMO_FILE}" -C /opt && \
#    rm "/opt/How to install Matomo.html" && \
#    git-clone-cached.sh \
#        --url https://github.com/digitalist-se/extratools.git \
#        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
#        --commit "${EXTRA_TOOLS_COMMIT}" \
#        --worktree /opt/matomo/plugins/ExtraTools

FROM ${repository}/nginx:${tag}

EXPOSE 8000

# The driver is given explicitly to prevent accidentially overriding as Matomo
# only supports MySQL.
ENV \
    MATOMO_ASSUME_SECURE_PROTOCOL=1 \
    MATOMO_DB_DRIVER=mysql \
    MATOMO_DB_NAME=matomo \
    MATOMO_DB_PASSWORD=password \
    MATOMO_DB_USER=matomo \
    MATOMO_DEFAULT_HOST=https://islandora.traefik.me \
    MATOMO_DEFAULT_NAME=Islandora \
    MATOMO_DEFAULT_TIMEZONE=America/Halifax \
    MATOMO_FORCE_SSL=1 \
    MATOMO_PROXY_CLIENT_HEADERS=HTTP_X_FORWARDED_FOR \
    MATOMO_PROXY_HOST_HEADERS=HTTP_X_FORWARDED_HOST \
    MATOMO_PROXY_URI_HEADER=1 \
    MATOMO_USER_EMAIL=admin@example.org \
    MATOMO_USER_NAME=admin \
    MATOMO_USER_PASS=password

WORKDIR /var/www/matomo

COPY --link --from=composer /opt/matomo /var/www/matomo

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
