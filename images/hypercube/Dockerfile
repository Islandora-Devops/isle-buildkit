# syntax=docker/dockerfile:1.20.0
FROM leptonica
FROM scyllaridae AS hypercube

ARG TARGETARCH

EXPOSE 8080

WORKDIR /app

ARG \
    # renovate: datasource=repology depName=alpine_3_22/poppler-utils
    POPPLER_VERSION=25.04.0-r0 \
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
    && cleanup.sh

COPY --link rootfs /
