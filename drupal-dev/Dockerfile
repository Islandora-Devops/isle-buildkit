# syntax=docker/dockerfile:experimental
FROM local/drupal:latest

RUN apk --no-cache add pcre-dev php7-pear php7-dev gcc musl-dev make \
  && pecl install xdebug \
  && apk del pcre-dev

COPY rootfs /

