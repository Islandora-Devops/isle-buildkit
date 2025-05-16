# syntax=docker/dockerfile:1.5.1
FROM imagemagick
FROM scyllaridae

ARG TARGETARCH

EXPOSE 8080

WORKDIR /app

# Platform specific does require arch specific identifier.
# Though platform information is included via the FROM imagemagick.
RUN --mount=type=bind,from=imagemagick,source=/packages,target=/packages \
    --mount=type=bind,from=imagemagick,source=/etc/apk/keys,target=/etc/apk/keys \
    apk add /packages/imagemagick-*.apk && \
    addgroup nginx jwt && \
    cleanup.sh

ENV \
    HOUDINI_FCREPO_URL=http://fcrepo:8080/fcrepo/rest \
    HOUDINI_LOG_LEVEL=info

COPY --link rootfs /

RUN chown -R nginx:nginx /var/www
