# syntax=docker/dockerfile:experimental
FROM local/nginx:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    MATOMO_VERSION="3.13.5" && \
    MATOMO_FILE="matomo-${MATOMO_VERSION}.tar.gz" && \
    MATOMO_URL="https://builds.matomo.org/${MATOMO_FILE}" && \
    MATOMO_FILE_SHA256="b9af7dabc6e727762cef58cecd16de7bc75886f8dacc910070632d83a44c2aad" && \
    MATOMO_SIG_SHA256="7e33ba4ea7f44370157832940d177d524b21192985b03e795e9f05f037b0c453" && \
    download.sh --url "${MATOMO_URL}" --sha256 "${MATOMO_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh --url "${MATOMO_URL}.asc" --sha256 "${MATOMO_SIG_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 814E346FA01A20DBB04B6807B5DBD5925590A237 && \
    gpg --verify "${DOWNLOAD_CACHE_DIRECTORY}/${MATOMO_FILE}.asc" "${DOWNLOAD_CACHE_DIRECTORY}/${MATOMO_FILE}" && \
    tar -xzf "${DOWNLOAD_CACHE_DIRECTORY}/${MATOMO_FILE}" -C /opt && \
    chown -R nginx:nginx /opt/matomo && \
    cleanup.sh

WORKDIR /opt/matomo

VOLUME [ "/opt/matomo/config" ]

COPY rootfs /

EXPOSE 8000
