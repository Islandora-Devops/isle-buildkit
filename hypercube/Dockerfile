# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/crayfish:${tag} AS crayfish

RUN --mount=type=cache,id=hypercube-composer,sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Hypercube && \
    ln -s /var/www/crayfish/Hypercube/src /var/www/html

FROM alpine:3.13.2 AS cache
FROM ${repository}/nginx:${tag}

EXPOSE 8000

RUN --mount=type=cache,id=hypercube-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add \
        poppler-utils \
        tesseract-ocr \
        tesseract-ocr-data-fra \
        tesseract-ocr-data-spa \
        tesseract-ocr-data-ita \
        tesseract-ocr-data-por \
        tesseract-ocr-data-hin \
        tesseract-ocr-data-deu \
        tesseract-ocr-data-jpn \
        tesseract-ocr-data-rus \
    && \
    addgroup nginx jwt && \
    cleanup.sh

ENV \
    HYPERCUBE_FCREPO_URL=fcrepo/fcrepo/rest \
    HYPERCUBE_LOG_LEVEL=debug

COPY --from=crayfish /etc/nginx/http.d/default.conf /etc/nginx/http.d/default.conf
COPY --from=crayfish --chown=nginx:nginx /var/www /var/www

COPY rootfs /

WORKDIR /var/www/crayfish/Hypercube/
