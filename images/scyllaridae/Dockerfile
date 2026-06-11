FROM base AS builder

WORKDIR /build

ARG TARGETARCH

# renovate: datasource=github-releases depName=scyllaridae packageName=islandora/scyllaridae
ARG SCYLLARIDAE_VERSION=5.2.10
ARG SCYLLARIDAE_URL="https://github.com/islandora/scyllaridae/archive/refs/tags/${SCYLLARIDAE_VERSION}.tar.gz"
ARG SCYLLARIDAE_SHA256="c68075673b604a7ffeeaffad5a50afa146e61e7047559a3d4d1c020975d0e484"
RUN download.sh \
      --url "${SCYLLARIDAE_URL}" \
      --sha256 "${SCYLLARIDAE_SHA256}" \
      --dest .

# renovate: datasource=golang-version depName=go versioning=semver
ARG GO_VERSION=go1.26.4
ARG \
  GO_BASE_URL="https://go.dev/dl/${GO_VERSION}" \
  GO_AMD64=linux-amd64.tar.gz	\
  GO_AMD64_SHA256="1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f" \
  GO_ARM64=linux-arm64.tar.gz \
  GO_ARM64_SHA256="ef758ae7c6cf9267c9c0ef080b8965f453d89ab2d25d9eb22de4405925238768"

RUN if [ "${TARGETARCH}" = "amd64" ]; \
    then \
        download.sh \
            --url "${GO_BASE_URL}.${GO_AMD64}" \
            --sha256 "${GO_AMD64_SHA256}" \
            --dest . ; \
    else \
        download.sh \
            --url "${GO_BASE_URL}.${GO_ARM64}" \
            --sha256 "${GO_ARM64_SHA256}" \
            --dest . ; \
    fi

RUN cd "./scyllaridae-${SCYLLARIDAE_VERSION}" && \
  ../go/bin/go build -o ../scyllaridae -ldflags="-s -w" .

FROM base

COPY --from=builder /build/scyllaridae /app/scyllaridae

ARG \
  # renovate: datasource=repology depName=alpine_3_24/mailcap
  MAILCAP_VERSION=2.1.54-r0

RUN --mount=type=cache,id=scyllaridae-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add mailcap=="${MAILCAP_VERSION}" && \
    create-service-user.sh --name scyllaridae && \
    cleanup.sh

ENV \
  SCYLLARIDAE_ALLOW_INSECURE_ARGS="false" \
  SCYLLARIDAE_LOG_LEVEL=INFO \
  SCYLLARIDAE_PORT=8080 \
  SCYLLARIDAE_YML_PATH="/app/scyllaridae.yml"

COPY --link rootfs /
