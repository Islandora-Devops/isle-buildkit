# syntax=docker/dockerfile:experimental
FROM islandora/crayfish:latest

RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \ 
    --mount=id=composer,sharing=locked,type=cache,target=/root/.composer/cache \
    apk-install.sh \
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
    composer install -d /var/www/crayfish/Hypercube && \
    ln -s /var/www/crayfish/Hypercube/src /var/www/html && \
    cleanup.sh

COPY /rootfs /

WORKDIR /var/www/crayfish/Hypercube/
