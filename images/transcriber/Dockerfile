# syntax=docker/dockerfile:1.20.0
FROM base AS build

ARG TARGETARCH
ARG \
  # renovate: datasource=repology depName=alpine_3_24/build-base
  BUILD_BASE_VERSION=0.5-r4 \
  # renovate: datasource=repology depName=alpine_3_24/cmake
  CMAKE_VERSION=4.2.3-r0

RUN --mount=type=cache,id=whisper-build-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        build-base=="${BUILD_BASE_VERSION}" \
        cmake=="${CMAKE_VERSION}"

# renovate: datasource=github-releases depName=whisper.cpp packageName=ggml-org/whisper.cpp
ARG WHISPER_VERSION=1.8.6
ARG WHISPER_URL="https://github.com/ggml-org/whisper.cpp/archive/refs/tags/v${WHISPER_VERSION}.tar.gz"
ARG WHISPER_SHA256="f8e632016ceae556f3132a16c7f704be1e7715595041f474fa81a2b64c1abf7c"
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
  # renovate: datasource=repology depName=alpine_3_24/ffmpeg
  FFMPEG_VERSION=8.1.1-r0 \
  # renovate: datasource=repology depName=alpine_3_24/sdl2
  SDL2_VERSION=2.32.10-r0

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
