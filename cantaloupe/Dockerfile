# syntax=docker/dockerfile:experimental
FROM local/tomcat:latest

# Opted for OpenJPG over Kakadu but that could be changed.
# For reference see: https://cantaloupe-project.github.io/manual/3.3/processors.html
RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \
    apk-install.sh \
        imagemagick \
        ffmpeg \
        openjpeg

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    CANTALOUPE_VERSION="4.1.5" && \
    CANTALOUPE_FILE="cantaloupe-${CANTALOUPE_VERSION}.zip" && \
    CANTALOUPE_URL="https://github.com/medusa-project/cantaloupe/releases/download/v${CANTALOUPE_VERSION}/${CANTALOUPE_FILE}" && \
    CANTALOUPE_SHA256="a117061727f1de1c0f514659ec537c080a7f540199643244d1c9cbb50d73027d" && \
    download.sh --url "${CANTALOUPE_URL}" --sha256 "${CANTALOUPE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    unzip "${DOWNLOAD_CACHE_DIRECTORY}/${CANTALOUPE_FILE}" -d /tmp && \
    CANTALOUPE_UNPACKED="${CANTALOUPE_FILE%.zip}" && \
    install-war-into-tomcat.sh --name "cantaloupe" --file "/tmp/${CANTALOUPE_UNPACKED}/${CANTALOUPE_UNPACKED}.war" && \
    rm -fr "/tmp/${CANTALOUPE_UNPACKED}" && \
    mkdir /data && \
    chown tomcat:tomcat /data && \
    chown -R tomcat:tomcat /opt/tomcat

COPY rootfs /
