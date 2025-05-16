# syntax=docker/dockerfile:1.5.1
FROM scyllaridae

ARG TARGETARCH

EXPOSE 8080

WORKDIR /app

ENV \
    CRAYFITS_LOG_LEVEL=info \
    CRAYFITS_WEBSERVICE_URI=http://fits:8080/fits/examine

COPY --link rootfs /
