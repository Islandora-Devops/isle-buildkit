# syntax=docker/dockerfile:1.5.1
FROM crayfish AS hypercube

ARG TARGETARCH

EXPOSE 8000

WORKDIR /var/www/crayfish/Hypercube

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=hypercube-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Hypercube && \
    ln -s /var/www/crayfish/Hypercube/public /var/www/html && \
    cleanup.sh

# Platform specific does require arch specific identifier.
# Though platform information is included via the FROM leptonica.
RUN --mount=type=cache,id=hypercube-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    --mount=type=bind,from=leptonica,source=/packages,target=/packages \
    --mount=type=bind,from=leptonica,source=/etc/apk/keys,target=/etc/apk/keys \
    apk add \
        /packages/leptonica-*.apk \
        poppler-utils \
        tesseract-ocr \
        tesseract-ocr-data-eng \
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

ENV HYPERCUBE_FCREPO_URL=fcrepo:8080/fcrepo/rest \
    HYPERCUBE_LOG_LEVEL=info

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
