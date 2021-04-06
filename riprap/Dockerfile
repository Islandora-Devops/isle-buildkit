# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/composer:${tag} AS composer

RUN --mount=type=cache,id=riprap-composer,sharing=locked,target=/root/.composer/cache \
    --mount=type=cache,id=riprap-downloads,sharing=locked,target=/opt/downloads \
    COMMIT=7d7cae2d09dec20caa3c3f5752434af32401819e && \
    git-clone-cached.sh \
        --url https://github.com/mjordan/riprap.git \
        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
        --commit "${COMMIT}" \
        --worktree /var/www/riprap && \
    composer install -d /var/www/riprap --no-dev

FROM alpine:3.13.2 AS cache
FROM ${repository}/nginx:${tag}

EXPOSE 8000

RUN --mount=type=cache,id=riprap-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add php7-pdo_sqlite && \
    cleanup.sh

# The driver is given explicitly as Rip Rap can be run on SQLite without
# further configuration.
ENV \
    RIPRAP_APP_ENV=dev \
    RIPRAP_APP_SECRET=f58c87e1d737c4422b45ba4310abede6 \
    RIPRAP_CROND_ENABLE_SERVICE=true \
    RIPRAP_CROND_LOG_LEVEL=8 \
    RIPRAP_CROND_SCHEDULE="0	0	1	*	*" \
    RIPRAP_DB_DRIVER=sqlite \
    RIPRAP_DB_NAME=riprap \
    RIPRAP_DB_PASSWORD=password \
    RIPRAP_DB_USER=riprap \
    RIPRAP_LOG_LEVEL=debug \
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

COPY --from=composer --chown=nginx:nginx /var/www /var/www

COPY rootfs /

WORKDIR /var/www/riprap