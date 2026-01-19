# syntax=docker/dockerfile:1.20.0
FROM scyllaridae

ARG TARGETARCH

EXPOSE 8080

WORKDIR /app

ARG \
    # renovate: datasource=repology depName=alpine_3_22/ffmpeg
    FFMPEG_VERSION=6.1.2-r2

# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=homarus-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add ffmpeg=="${FFMPEG_VERSION}" && \
    cleanup.sh

COPY --link rootfs /
