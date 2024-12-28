# syntax=docker/dockerfile:1.5.1
FROM nodejs
FROM drupal

ARG TARGETARCH

# renovate: datasource=github-releases depName=alpine-pkg-glibc packageName=sgerrand/alpine-pkg-glibc
ARG GLIBC_VERSION="2.35-r1"
ARG GLIBC_FILE="glibc-${GLIBC_VERSION}.apk"
ARG GLIBC_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${GLIBC_FILE}"
ARG GLIBC_SHA256="276f43ce9b2d5878422bca94ca94e882a7eb263abe171d233ac037201ffcaf06"

EXPOSE 8443 \
       9003

RUN --mount=type=cache,id=code-server-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    download.sh \
        --url "${GLIBC_URL}" \
        --sha256 "${GLIBC_SHA256}" \
    && \
    apk add "${DOWNLOAD_CACHE_DIRECTORY}/${GLIBC_FILE}" && \
    mkdir /lib64 && \
    ln -s /lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2 && \
    cleanup.sh

RUN --mount=type=bind,source=rootfs/var/lib/nginx/.composer,target=/composer \
    --mount=type=cache,id=code-server-composer-${TARGETARCH},sharing=locked,target=/var/lib/nginx/.composer/cache \
    mkdir -p /var/lib/nginx/.composer && \
    cp -r /composer/* /var/lib/nginx/.composer && \
    ls -lah /var/lib/nginx/.composer && \
    composer install -n -d /var/lib/nginx/.composer && \
    cleanup.sh

# Include commonly used tools and xdebug.
# PHPStorm remote requries Glibc.
RUN --mount=type=cache,id=code-server-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    --mount=type=bind,from=nodejs,source=/packages,target=/packages \
    --mount=type=bind,from=nodejs,source=/etc/apk/keys,target=/etc/apk/keys \
    apk add \
        /packages/nodejs-*.apk \
        alpine-sdk \
        docker-cli \
        htop \
        krb5-dev \
        openssh \
        parallel \
        php83-pecl-xdebug \
        python3 \
        spdlog \
        sudo \
        unison \
        npm \
    && \
    cleanup.sh

RUN --mount=type=cache,id=code-server-npm-${TARGETARCH},sharing=locked,target=/root/.npm \
    CXXFLAGS='-DNODE_API_EXPERIMENTAL_NOGC_ENV_OPT_OUT -U_FORTIFY_SOURCE' npm install --global --unsafe-perm code-server@4.91.1 && \
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

COPY --link rootfs /

# Install Editor plugins from bind mounted folder (Not available on online marketplace).
RUN --mount=type=bind,source=/extensions,target=/extensions \
    declare -a PIDS=() EXTENSIONS=(/extensions/*.vsix); \
    EXTENSIONS+=(\
        bmewburn.vscode-intelephense-client \
        felixfbecker.php-debug \
        streetsidesoftware.code-spell-checker \
        mblode.twig-language-2 \
    ) && \
    mkdir -p /opt/code-server/data /opt/code-server/extensions; \
    for extension in "${EXTENSIONS[@]}"; \
    do \
        code-server \
            --config /opt/code-server/config.yaml \
            --user-data-dir /opt/code-server/data \
            --extensions-dir /opt/code-server/extensions \
            --install-extension="${extension}"; \
    done; \
    chown -R nginx:nginx /opt/code-server && \
    cleanup.sh

# Set a default shell so it can be used via code-server.
# Additionally https://github.com/sudo-project/sudo/issues/42
RUN sed -i "/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/cnginx:x:100:101:nginx:/var/lib/nginx:/bin/bash" /etc/passwd && \
    mkdir -p /var/lib/nginx/.local && \
    chown -R nginx:nginx /var/lib/nginx && \
    chmod a=r,u+w /etc/sudo.conf && \
    cleanup.sh
