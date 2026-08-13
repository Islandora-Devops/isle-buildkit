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
ARG WHISPER_VERSION=1.9.2
ARG WHISPER_URL="https://github.com/ggml-org/whisper.cpp/archive/refs/tags/v${WHISPER_VERSION}.tar.gz"
ARG WHISPER_SHA256="a6abd064fcca8b85e794d205abf328c522e9451db43a3eadc178b883b7d0e9cd"
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

# Avoid -march=native: CI builders may expose AVX-512 instructions that are
# unavailable on the hosts running the published image.
RUN make \
      CMAKE_ARGS="-DGGML_NATIVE=OFF -DGGML_BMI2=OFF" \
      "${WHISPER_MODEL}"

FROM scyllaridae

ARG TARGETARCH
EXPOSE 8080
WORKDIR /app

ARG \
  # renovate: datasource=repology depName=alpine_3_24/ffmpeg
  FFMPEG_VERSION=8.1.2-r0 \
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
