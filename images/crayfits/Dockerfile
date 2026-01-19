# syntax=docker/dockerfile:1.20.0
FROM scyllaridae

ARG TARGETARCH

EXPOSE 8080

WORKDIR /app

ENV \
    CRAYFITS_WEBSERVICE_URI=http://fits:8080/fits/examine

COPY --link rootfs /
