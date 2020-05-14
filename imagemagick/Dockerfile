# syntax=docker/dockerfile:experimental
FROM islandora/abuild:latest

RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \ 
    apk --update add \
    	libheif-dev \
    	libwebp-dev \
        chrpath \
        fftw-dev \
        fontconfig-dev \
        freetype-dev \
        ghostscript-dev \
        ghostscript-fonts \
        graphviz \
        lcms2-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        librsvg-dev \
        libtool \
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

ARG PACKAGER="Nigel Banks <nigel.g.banks@gmail.com>" 

USER builder

RUN export PACKAGER="${PACKAGER}" && \
    abuild-keygen -ain && \
    abuild-apk update && \
    abuild
