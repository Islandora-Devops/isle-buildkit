# syntax=docker/dockerfile:1.2.1
FROM local/crayfish:latest

RUN --mount=type=cache,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Gemini && \
    ln -s /var/www/crayfish/Gemini/src /var/www/html && \
    cleanup.sh

COPY /rootfs /

WORKDIR /var/www/crayfish/Gemini/
