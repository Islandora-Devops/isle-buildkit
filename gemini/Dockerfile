# syntax=docker/dockerfile:experimental
FROM local/crayfish:latest

RUN --mount=type=cache,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Gemini && \
    ln -s /var/www/crayfish/Gemini/src /var/www/html && \
    cleanup.sh

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

COPY /rootfs /

WORKDIR /var/www/crayfish/Gemini/
