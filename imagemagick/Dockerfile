# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM alpine:3.15.0 AS cache
FROM ${repository}/abuild:${tag} AS build

RUN --mount=type=cache,id=imagemagick-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add \
        chrpath \
        fftw-dev \
        fontconfig-dev \
        freetype-dev \
        ghostscript-dev \
        ghostscript-fonts \
        graphviz \
        lcms2-dev \
        libheif-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        librsvg-dev \
        libtool \
        libwebp-dev \
        libwmf-dev \
        libx11-dev \
        libxext-dev \
        libxml2-dev \
        openexr-dev \
        openjpeg-dev \
        pango-dev \
        perl-dev \
        tiff-dev \
        zlib-dev

COPY /build /build

WORKDIR /build

RUN chown -R builder /build

USER builder

RUN export PACKAGER="Nigel Banks <nigel.g.banks@gmail.com>" && \
    abuild-keygen -ain && \
    abuild-apk update && \
    abuild

FROM alpine:3.15.0

COPY --from=build /etc/apk/keys /etc/apk/keys
COPY --from=build /home/builder/packages/*/ /packages