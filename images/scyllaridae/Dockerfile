FROM base AS builder

WORKDIR /build

ARG TARGETARCH

# renovate: datasource=github-releases depName=scyllaridae packageName=islandora/scyllaridae
ARG SCYLLARIDAE_VERSION=5.2.1
ARG SCYLLARIDAE_URL="https://github.com/islandora/scyllaridae/archive/refs/tags/${SCYLLARIDAE_VERSION}.tar.gz"
ARG SCYLLARIDAE_SHA256="547aa1f3a5efed7caf5f73b00f2fa74320a1e0433f37c35ea1a0cf372cdb9a40"
RUN download.sh \
      --url "${SCYLLARIDAE_URL}" \
      --sha256 "${SCYLLARIDAE_SHA256}" \
      --dest .

# renovate: datasource=github-tags depName=golang packageName=golang/go versioning=go-mod-directive
ARG GO_VERSION=go1.25.3
ARG \
  GO_BASE_URL="https://go.dev/dl/${GO_VERSION}" \
  GO_AMD64=linux-amd64.tar.gz	\
  GO_AMD64_SHA256="0335f314b6e7bfe08c3d0cfaa7c19db961b7b99fb20be62b0a826c992ad14e0f" \
  GO_ARM64=linux-arm64.tar.gz \
  GO_ARM64_SHA256="1d42ebc84999b5e2069f5e31b67d6fc5d67308adad3e178d5a2ee2c9ff2001f5"

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
  # renovate: datasource=repology depName=alpine_3_22/mailcap
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
