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
    CANTALOUPE_VERSION="4.1.5" && \
    wget -N -P /opt/downloads "https://github.com/medusa-project/cantaloupe/releases/download/v${CANTALOUPE_VERSION}/cantaloupe-${CANTALOUPE_VERSION}.zip" && \
    unzip "/opt/downloads/cantaloupe-${CANTALOUPE_VERSION}.zip" -d /tmp && \
    install-war-into-tomcat.sh \
        --name "cantaloupe" \
        --file "/tmp/cantaloupe-${CANTALOUPE_VERSION}/cantaloupe-${CANTALOUPE_VERSION}.war" \
        --key "fb7dc129ec1c1f965e5c4459743730af92fb9001a8fe79632c3ed17ecefc0fe3" && \
    rm -fr /tmp/Cantaloupe-*


COPY rootfs /

RUN mkdir /data && \
    chown tomcat:tomcat /data && \
    chown -R tomcat:tomcat /opt/tomcat

VOLUME /data
