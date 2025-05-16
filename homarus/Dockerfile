# syntax=docker/dockerfile:1.5.1
FROM scyllaridae

ARG TARGETARCH

EXPOSE 8080

WORKDIR /app

ARG \
    # renovate: datasource=repology depName=alpine_3_20/ffmpeg
    FFMPEG_VERSION=6.1.1-r8

# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=homarus-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add ffmpeg=="${FFMPEG_VERSION}" && \
    addgroup nginx jwt && \
    cleanup.sh

ENV \
    HOMARUS_APIX_MIDDLEWARE_ENABLED=false \
    HOMARUS_FCREPO_URL=http://fcrepo:8080/fcrepo/rest \
    HOMARUS_LOG_LEVEL=info

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
