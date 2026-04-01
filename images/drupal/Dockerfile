# syntax=docker/dockerfile:1.20.0
FROM leptonica
FROM imagemagick
FROM scyllaridae
FROM hypercube
FROM houdini
FROM homarus
FROM crayfits
FROM mergepdf
FROM nginx

ARG TARGETARCH

EXPOSE 80

WORKDIR /var/www/drupal

ARG \
    # renovate: datasource=repology depName=alpine_3_22/ffmpeg
    FFMPEG_VERSION=6.1.2-r2 \
    # renovate: datasource=repology depName=alpine_3_22/poppler-utils
    POPPLER_VERSION=25.04.0-r0 \
    # renovate: datasource=repology depName=alpine_3_22/tesseract-ocr
    TESSERACT_VERSION=5.5.0-r2

# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=drupal-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    --mount=type=bind,from=leptonica,source=/packages,target=/packages/leptonica \
    --mount=type=bind,from=leptonica,source=/etc/apk/keys,target=/keys/leptonica \
    --mount=type=bind,from=imagemagick,source=/packages,target=/packages/imagemagick \
    --mount=type=bind,from=imagemagick,source=/etc/apk/keys,target=/keys/imagemagick \
    mkdir -p \
        /opt/scyllaridae/crayfits \
        /opt/scyllaridae/homarus \
        /opt/scyllaridae/houdini \
        /opt/scyllaridae/hypercube \
        /var/www/drupal/config \
        /var/www/drupal/web/libraries \
    && \
    cp /keys/leptonica/* /etc/apk/keys/ \
    && \
    cp /keys/imagemagick/* /etc/apk/keys/ \
    && \
    apk add \
        /packages/imagemagick/imagemagick-*.apk \
        /packages/leptonica/leptonica-*.apk \
        ffmpeg=="${FFMPEG_VERSION}" \
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
    && \
    chown -R nginx:nginx /var/www && \
    addgroup nginx jwt && \
    cleanup.sh

# Installation typically needs more than the default 30 seconds defined in the
# base image. Set to 10 minutes just incase it ran on very old or overallocated
# hardware.
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=600000

ENV \
    DRUPAL_DEFAULT_ACCOUNT_EMAIL=webmaster@localhost.com \
    DRUPAL_DEFAULT_ACCOUNT_NAME=admin \
    DRUPAL_DEFAULT_ACCOUNT_PASSWORD=password \
    DRUPAL_DEFAULT_BROKER_HOST=activemq \
    DRUPAL_DEFAULT_BROKER_PORT=61613 \
    DRUPAL_DEFAULT_BROKER_URL=tcp://activemq:61613 \
    DRUPAL_DEFAULT_BROKER_WEB_ADMIN_PASSWORD=password \
    DRUPAL_DEFAULT_BROKER_WEB_ADMIN_USER=admin \
    DRUPAL_DEFAULT_BROKER_WEB_PORT=8161 \
    DRUPAL_DEFAULT_CANTALOUPE_URL=https://islandora.traefik.me/cantaloupe/iiif/2 \
    DRUPAL_DEFAULT_CONFIGDIR=/var/www/drupal/config/sync \
    DRUPAL_DEFAULT_DB_NAME=drupal_default \
    DRUPAL_DEFAULT_DB_PASSWORD=password \
    DRUPAL_DEFAULT_DB_USER=drupal_default \
    DRUPAL_DEFAULT_EMAIL=webmaster@localhost.com \
    DRUPAL_DEFAULT_FCREPO_HOST=islandora.traefik.me \
    DRUPAL_DEFAULT_FCREPO_PORT=8081 \
    DRUPAL_DEFAULT_FITS_HOST=fits \
    DRUPAL_DEFAULT_FITS_PORT=8080 \
    DRUPAL_DEFAULT_INSTALL_EXISTING_CONFIG=false \
    DRUPAL_DEFAULT_INSTALL=true \
    DRUPAL_DEFAULT_LOCALE=en \
    DRUPAL_DEFAULT_NAME=Default \
    DRUPAL_DEFAULT_PROFILE=standard \
    DRUPAL_DEFAULT_SALT=9PPaL0CxZAIcq0l9wxgDGlCZrp7JdT_x7v9gVzpdbUjMt1PqDz3uD0Zy-i16DuJ1-Htuq5hqeg \
    DRUPAL_DEFAULT_SITE_URL=https://islandora.traefik.me \
    DRUPAL_DEFAULT_SOLR_CORE=ISLANDORA \
    DRUPAL_DEFAULT_SOLR_HOST=solr \
    DRUPAL_DEFAULT_SOLR_PORT=8983 \
    DRUPAL_DEFAULT_SUBDIR=default \
    DRUPAL_DEFAULT_TRIPLESTORE_HOST=blazegraph \
    DRUPAL_DEFAULT_TRIPLESTORE_NAMESPACE=islandora \
    DRUPAL_DEFAULT_TRIPLESTORE_PORT=8080 \
    DRUPAL_ENABLE_HTTPS=true \
    DRUPAL_REVERSE_PROXY_IPS= \
    DRUPAL_SITES=DEFAULT

COPY --link rootfs /
COPY --link --from=scyllaridae /app/scyllaridae /usr/bin/scyllaridae
COPY --link --from=crayfits /app/scyllaridae.yml /opt/scyllaridae/crayfits/scyllaridae.yml
COPY --link --from=homarus /app/scyllaridae.yml /opt/scyllaridae/homarus/scyllaridae.yml
COPY --link --from=homarus /app/cmd.sh /opt/scyllaridae/homarus/cmd.sh
COPY --link --from=houdini /app/scyllaridae.yml /opt/scyllaridae/houdini/scyllaridae.yml
COPY --link --from=houdini /app/cmd.sh /opt/scyllaridae/houdini/cmd.sh
COPY --link --from=hypercube /app/scyllaridae.yml /opt/scyllaridae/hypercube/scyllaridae.yml
COPY --link --from=hypercube /app/cmd.sh /opt/scyllaridae/hypercube/cmd.sh
COPY --link --from=mergepdf /app/scyllaridae.yml /opt/scyllaridae/mergepdf/scyllaridae.yml
COPY --link --from=mergepdf /app/cmd.sh /opt/scyllaridae/mergepdf/cmd.sh


RUN chown -R nginx:nginx /var/www /usr/share/drush
