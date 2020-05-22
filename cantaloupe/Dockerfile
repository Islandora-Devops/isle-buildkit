# syntax=docker/dockerfile:experimental
FROM local/tomcat:latest

# Opted for OpenJPG over Kakadu but that could be changed.
# Check 00-cantaloupe-setup-environment for the defaults.
# For reference see: https://cantaloupe-project.github.io/manual/3.3/processors.html
RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \
    apk-install.sh \
        imagemagick \
        ffmpeg \
        openjpeg

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    CANTALOUPE_VERSION="3.3.1" && \
    wget -N -P /opt/downloads "https://github.com/medusa-project/cantaloupe/releases/download/v${CANTALOUPE_VERSION}/Cantaloupe-${CANTALOUPE_VERSION}.zip" && \
    unzip "/opt/downloads/Cantaloupe-${CANTALOUPE_VERSION}.zip" -d /tmp && \
    install-war-into-tomcat.sh \
        --name "cantaloupe" \
        --file "/tmp/Cantaloupe-${CANTALOUPE_VERSION}/Cantaloupe-${CANTALOUPE_VERSION}.war" \
        --key "a56593bae377b4db6b1e0cd5c8a9d62fdda41632f6295b5d4fe846e66c15768a" && \
    rm -fr /tmp/Cantaloupe-*


COPY rootfs /

RUN mkdir /data && \
    chown tomcat:tomcat /data && \
    chown -R tomcat:tomcat /opt/tomcat

VOLUME /data
