# syntax=docker/dockerfile:1.20.0
FROM base AS build

ARG TARGETARCH
ARG \
    # renovate: datasource=repology depName=alpine_3_22/build-base
    BUILD_BASE_VERSION=0.5-r3 \
    # renovate: datasource=repology depName=alpine_3_22/cmake
    CMAKE_VERSION=3.31.7-r1

RUN --mount=type=cache,id=whisper-build-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        build-base=="${BUILD_BASE_VERSION}" \
        cmake=="${CMAKE_VERSION}"

# renovate: datasource=github-releases depName=whisper.cpp packageName=ggml-org/whisper.cpp
ARG WHISPER_VERSION=1.8.3
ARG WHISPER_URL="https://github.com/ggml-org/whisper.cpp/archive/refs/tags/v${WHISPER_VERSION}.tar.gz"
ARG WHISPER_SHA256="870ba21409cdf66697dc4db15ebdb13bc67037d76c7cc63756c81471d8f1731a"
# whisper model to include in this image
# see https://github.com/ggml-org/whisper.cpp#more-audio-samples for options
ARG WHISPER_MODEL=medium.en

WORKDIR /build
RUN download.sh \
      --url "${WHISPER_URL}" \
      --sha256 "${WHISPER_SHA256}" \
      --dest . && \
    mv whisper.cpp-${WHISPER_VERSION} whisper.cpp

WORKDIR /build/whisper.cpp

RUN make "${WHISPER_MODEL}"

FROM scyllaridae

ARG TARGETARCH
EXPOSE 8080
WORKDIR /app

ARG \
    # renovate: datasource=repology depName=alpine_3_22/ffmpeg
    FFMPEG_VERSION=6.1.2-r2 \
    # renovate: datasource=repology depName=alpine_3_22/sdl2
    SDL2_VERSION=2.32.8-r0

RUN --mount=type=cache,id=whisper-runtime-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        ffmpeg=="${FFMPEG_VERSION}" \
        sdl2-dev=="${SDL2_VERSION}" \
    && \
    cleanup.sh

COPY --from=build /build/whisper.cpp/build/src/libwhisper.so* /usr/local/lib/
COPY --from=build /build/whisper.cpp/build/ggml/src/libggml* /usr/local/lib/
COPY --from=build /build/whisper.cpp/build/bin/whisper-cli /app/
COPY --from=build /build/whisper.cpp/models /app/models

ENV \
    WHISPER_PROCESSORS=1 \
    WHISPER_THREADS=2

COPY --link rootfs /
