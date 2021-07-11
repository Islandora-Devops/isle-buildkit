# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

RUN --mount=type=cache,id=matomo-downloads,sharing=locked,target=/opt/downloads \
    MATOMO_VERSION="3.13.5" && \
    MATOMO_FILE="matomo-${MATOMO_VERSION}.tar.gz" && \
    MATOMO_URL="https://builds.matomo.org/${MATOMO_FILE}" && \
    MATOMO_FILE_SHA256="b9af7dabc6e727762cef58cecd16de7bc75886f8dacc910070632d83a44c2aad" && \
    download.sh --url "${MATOMO_URL}" --sha256 "${MATOMO_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    tar -xzf "${DOWNLOAD_CACHE_DIRECTORY}/${MATOMO_FILE}" -C /opt && \
    rm "/opt/How to install Matomo.html"

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
    MATOMO_SALT=5a472390550bd59e4428a41aa472137b \
    MATOMO_USER_EMAIL=admin@example.org \
    MATOMO_USER_NAME=admin \
    MATOMO_USER_PASS='$2y$10$S38e7HPM9LI3aOIvcnRsfuMCm4ipNP572QsvbCK60upoHVJ61hMrS'

COPY --from=download --chown=nginx:nginx /opt/matomo /var/www/matomo

COPY rootfs /

WORKDIR /var/www/matomo