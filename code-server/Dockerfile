# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM alpine:3.13.2 AS cache
FROM ${repository}/abuild:${tag} AS build

# g++, make, python are only required to build native dependencies via node-gyp.
# spdlog is required for building / using xdebug extension.
RUN --mount=type=cache,id=code-server-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add \
        bash \
        g++ \
        make \
        nghttp2-dev \
        python3 \
        spdlog \
        sudo \
        yarn

# `node-gyp` must be installed before anything else. This is unfortuante, but
# make sure the version here matches the exact version in:
# `rootfs/usr/local/share/.config/yarn/global/package.json`
RUN --mount=type=cache,id=code-server-yarn,sharing=locked,from=cache,target=/usr/local/share/.cache/yarn \
    yarn global add node-gyp@9.0.0

COPY rootfs/usr/local/share/.config/yarn/global /usr/local/share/.config/yarn/global

RUN --mount=type=cache,id=code-server-yarn,sharing=locked,from=cache,target=/usr/local/share/.cache/yarn \
    cd /usr/local/share/.config/yarn/global && \
    JOBS=max yarn install

SHELL ["/bin/bash", "-c"]

# Install Editor plugins from bind mounted folder (Not available on online marketplace).
RUN --mount=type=bind,source=/extensions,target=/extensions \
    for extension in /extensions/*.vsix; \
    do \
        /usr/local/share/.config/yarn/global/node_modules/.bin/code-server \
            --config /opt/code-server/config.yaml \
            --user-data-dir /opt/code-server/data \
            --extensions-dir /opt/code-server/extensions \
            --install-extension="${extension}" & \
    done; \
    wait

# Install Editor plugins from internet (saves downloading when installing).
RUN --mount=type=cache,id=code-server-extensions,sharing=locked,from=cache,target=/opt/code-server/.local/share/code-server/CachedExtensionVSIXs \
    EXTENSIONS=(\
        bmewburn.vscode-intelephense-client \
        felixfbecker.php-debug \
        streetsidesoftware.code-spell-checker \
        mblode.twig-language-2 \
    ) && \
    for extension in "${EXTENSIONS[@]}"; \
    do \
        /usr/local/share/.config/yarn/global/node_modules/.bin/code-server \
            --config /opt/code-server/config.yaml \
            --user-data-dir /opt/code-server/data \
            --extensions-dir /opt/code-server/extensions \
            --install-extension="${extension}" & \
    done; \
    wait

FROM --platform=$BUILDPLATFORM ${repository}/composer:${tag} AS composer

COPY rootfs/root/.composer /root/.composer

RUN --mount=type=cache,id=code-server-composer,sharing=locked,target=/root/.composer/cache \
    cd /root/.composer && \
    composer install -n 

FROM ${repository}/drupal:${tag}

EXPOSE 8443 \
       9003

# Set a default shell so it can be used via code-server.
RUN sed -i "/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/cnginx:x:100:101:nginx:/var/lib/nginx:/bin/bash" /etc/passwd

# Include commonly used tools and xdebug.
RUN --mount=type=cache,id=code-server-drupal-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk --update add \
        htop \
        php7-pecl-xdebug \
        spdlog \
        yarn \
        sudo \
        unison \
        parallel \
    && \
    cleanup.sh

# Drush requires HOME to be set as such.
ENV \
    HOME="/var/lib/nginx" \
    PATH=$PATH:/var/lib/nginx/.composer/vendor/bin:/var/www/drupal/vendor/bin

# Code server / xdebug settings.
ENV \
    CODE_SERVER_AUTHENTICATION=password \
    CODE_SERVER_PASSWORD=password \
    XDEBUG_FLAGS="-d xdebug.mode=develop,debug"

COPY --from=composer --chown=nginx:nginx /root/.composer /var/lib/nginx/.composer
COPY --from=build --chown=nginx:nginx /opt/code-server /opt/code-server
COPY --from=build /usr/local/share/.config/yarn /usr/local/share/.config/yarn

COPY rootfs /

RUN ln -s /usr/local/share/.config/yarn/global/node_modules/.bin/code-server /usr/local/bin/code-server && \
    ln -s /usr/local/share/.config/yarn/global/node_modules/.bin/node-gyp /usr/local/bin/node-gyp && \
    ln -s /usr/local/share/.config/yarn/global/node_modules/.bin/grunt /usr/local/bin/grunt && \
    ln -s /usr/local/share/.config/yarn/global/node_modules/.bin/bower /usr/local/bin/bower

# https://github.com/sudo-project/sudo/issues/42
RUN chmod a=r,u+w /etc/sudo.conf
