# syntax=docker/dockerfile:experimental
FROM local/nginx:latest

RUN mkdir -p /var/www/drupal && chown nginx:nginx /var/www/drupal

WORKDIR /var/www/drupal

COPY rootfs /

EXPOSE 80