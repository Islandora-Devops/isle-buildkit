# syntax=docker/dockerfile:experimental
FROM local/nginx:latest

RUN mkdir -p /var/www/drupal && \
    chown nginx:nginx /var/www/drupal && \
    mkdir -p /opt/keys/jwt && \
    chown nginx:nginx /opt/keys/jwt

WORKDIR /var/www/drupal

COPY rootfs /

EXPOSE 80
