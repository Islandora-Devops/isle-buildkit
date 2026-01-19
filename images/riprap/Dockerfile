# syntax=docker/dockerfile:1.20.0
FROM nginx as download

ARG TARGETARCH
ARG COMMIT=6e38c75c1af3ee92a4fc54f8b8e36bc294812421
ARG FILE=${COMMIT}.tar.gz
ARG URL=https://github.com/mjordan/riprap/archive/${FILE}
ARG SHA256=b5de7767ca570cdfa8d44d7a8ab56165982b11058b4853494773776d232541c3

EXPOSE 8000

WORKDIR /var/www/riprap

ARG \
    # renovate: datasource=repology depName=alpine_3_22/php83
    PHP_VERSION=8.3.29-r0

# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=riprap-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add php83-pdo_sqlite=="${PHP_VERSION}" && \
    cleanup.sh

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=riprap-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${URL}" \
        --sha256 "${SHA256}" \
        --strip \
        --dest "/var/www/riprap" \
    cleanup.sh

FROM download

RUN --mount=type=cache,id=riprap-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    --mount=type=bind,source=rootfs/var/www/riprap/composer.lock,target=/var/www/riprap/composer.lock \
    composer install -d /var/www/riprap --no-dev && \
    cleanup.sh

# The driver is given explicitly as Rip Rap can be run on SQLite without
# further configuration.
ENV \
    RIPRAP_APP_ENV=dev \
    RIPRAP_APP_SECRET=f58c87e1d737c4422b45ba4310abede6 \
    RIPRAP_CROND_ENABLE_SERVICE=false \
    RIPRAP_CROND_LOG_LEVEL=8 \
    RIPRAP_CROND_SCHEDULE="0	0	1	*	*" \
    RIPRAP_DB_DRIVER=sqlite \
    RIPRAP_DB_NAME=riprap \
    RIPRAP_DB_PASSWORD=password \
    RIPRAP_DB_USER=riprap \
    RIPRAP_LOG_LEVEL=info \
    RIPRAP_MAILER_URL=null://localhost \
    RIPRAP_TRUSTED_HOSTS="" \
    RIPRAP_TRUSTED_PROXIES=""

# Configuration specific to check fixity command:
ENV \
    RIPRAP_CONFIG_DIGEST_COMMAND=/usr/bin/sha1sum \
    RIPRAP_CONFIG_DRUPAL_BASEURL=https://islandora.traefik.me \
    RIPRAP_CONFIG_DRUPAL_CONTENT_TYPES="['islandora_object']" \
    RIPRAP_CONFIG_DRUPAL_FILE_FIELDNAMES="['field_media_audio', 'field_media_document', 'field_edited_text', 'field_media_file', 'field_media_image', 'field_media_video_file']" \
    RIPRAP_CONFIG_DRUPAL_MEDIA_AUTH="['admin', 'islandora']" \
    RIPRAP_CONFIG_DRUPAL_MEDIA_TAGS="[]" \
    RIPRAP_CONFIG_DRUPAL_PASSWORD=password \
    RIPRAP_CONFIG_DRUPAL_USER=admin \
    RIPRAP_CONFIG_EMAIL_FROM="" \
    RIPRAP_CONFIG_EMAIL_TO="" \
    RIPRAP_CONFIG_FAILURES_LOG_PATH=var/riprap_failed_events.log \
    RIPRAP_CONFIG_FEDORAAPI_DIGEST_HEADER_LEADER_PATTERN="^.+=" \
    RIPRAP_CONFIG_FEDORAAPI_METHOD=HEAD \
    RIPRAP_CONFIG_FIXITY_ALGORITHM=sha1 \
    RIPRAP_CONFIG_GEMINI_AUTH_HEADER="Bearer islandora" \
    RIPRAP_CONFIG_GEMINI_ENDPOINT=http://gemini:8000 \
    RIPRAP_CONFIG_JSONAPI_AUTHORIZATION_HEADERS="" \
    RIPRAP_CONFIG_JSONAPI_PAGE_SIZE=50 \
    RIPRAP_CONFIG_JSONAPI_PAGER_DATA_FILE_PATH=var/fetchresourcelist.from.drupal.pager.txt \
    RIPRAP_CONFIG_MAX_RESOURCES=1000 \
    RIPRAP_CONFIG_OUTPUT_CSV_PATH=var/riprap_events.csv \
    RIPRAP_CONFIG_PLUGINS_FETCHDIGEST=PluginFetchDigestFromShell \
    RIPRAP_CONFIG_PLUGINS_FETCHRESOURCELIST="['PluginFetchResourceListFromFile']" \
    RIPRAP_CONFIG_PLUGINS_PERSIST=PluginPersistToDatabase \
    RIPRAP_CONFIG_PLUGINS_POSTCHECK="['PluginPostCheckCopyFailures']" \
    RIPRAP_CONFIG_RESOURCE_DIR_PATHS="" \
    RIPRAP_CONFIG_RESOURCE_LIST_PATH="['resources/csv_file_list.csv']" \
    RIPRAP_CONFIG_THIN=false \
    RIPRAP_CONFIG_USE_FEDORA_URLS=true \
    RIPRAP_CONFIG_VIEWS_PAGER_DATA_FILE_PATH=var/fetchresourcelist.from.drupal.pager.txt

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
