# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/crayfish:${tag} AS download

RUN --mount=type=cache,id=gemini-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Gemini && \
    ln -s /var/www/crayfish/Gemini/src /var/www/html

FROM ${repository}/crayfish:${tag}

COPY --from=download /var/www /var/www

ENV \
    GEMINI_DB_DRIVER=pdo_mysql \
    GEMINI_DB_HOST=mariadb \
    GEMINI_DB_NAME=gemini \
    GEMINI_DB_PASSWORD=password \
    GEMINI_DB_PORT=3306 \
    GEMINI_DB_ROOT_PASSWORD=password \
    GEMINI_DB_ROOT_USER=root \
    GEMINI_DB_USER=gemini \
    GEMINI_FCREPO_URL=http://fcrepo/fcrepo/rest \
    GEMINI_LOG_LEVEL=debug

COPY rootfs /

WORKDIR /var/www/crayfish/Gemini/
