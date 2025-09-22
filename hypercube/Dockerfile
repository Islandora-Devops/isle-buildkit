# syntax=docker/dockerfile:1.5.1
FROM leptonica
FROM crayfish AS hypercube

ARG TARGETARCH

EXPOSE 8000

WORKDIR /var/www/crayfish/Hypercube

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=hypercube-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/crayfish/Hypercube && \
    ln -s /var/www/crayfish/Hypercube/public /var/www/html && \
    cleanup.sh

ARG \
    # renovate: datasource=repology depName=alpine_3_22/poppler-utils
    POPPLER_VERSION=24.02.0-r2 \
    # renovate: datasource=repology depName=alpine_3_22/tesseract-ocr
    TESSERACT_VERSION=5.5.0-r2

# Platform specific does require arch specific identifier.
# Though platform information is included via the FROM leptonica.
RUN --mount=type=cache,id=hypercube-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    --mount=type=bind,from=leptonica,source=/packages,target=/packages \
    --mount=type=bind,from=leptonica,source=/etc/apk/keys,target=/etc/apk/keys \
    apk add \
        /packages/leptonica-*.apk \
        poppler-utils=="${POPPLER_VERSION}" \
        tesseract-ocr=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-eng=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-fra=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-spa=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-ita=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-por=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-hin=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-deu=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-jpn=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-rus=="${TESSERACT_VERSION}" \
    && \
    addgroup nginx jwt && \
    cleanup.sh

ENV HYPERCUBE_FCREPO_URL=fcrepo:8080/fcrepo/rest \
    HYPERCUBE_LOG_LEVEL=info

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
