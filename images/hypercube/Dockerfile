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
        tesseract-ocr-data-afr=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-ara=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-aze=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-bel=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-ben=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-bul=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-cat=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-ces=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-chi_sim=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-chi_tra=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-chr=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-dan=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-deu=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-eng=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-enm=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-epo=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-equ=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-est=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-eus=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-fin=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-fra=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-frk=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-frm=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-glg=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-grc=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-heb=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-hin=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-hrv=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-hun=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-ind=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-isl=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-ita=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-ita_old=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-jpn=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-kan=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-kat=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-khm=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-kor=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-lat=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-lav=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-lit=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-mal=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-mkd=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-mlt=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-msa=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-nld=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-nor=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-osd=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-pol=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-por=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-ron=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-rus=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-slk=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-slv=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-spa=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-spa_old=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-sqi=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-srp=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-swa=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-swe=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-tam=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-tel=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-tgl=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-tha=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-tur=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-ukr=="${TESSERACT_VERSION}" \
        tesseract-ocr-data-vie=="${TESSERACT_VERSION}" \
    && cleanup.sh

COPY --link rootfs /
