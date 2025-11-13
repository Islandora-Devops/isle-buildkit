FROM base AS builder

WORKDIR /build

ARG TARGETARCH

# renovate: datasource=github-releases depName=scyllaridae packageName=islandora/scyllaridae
ARG SCYLLARIDAE_VERSION=insecure-args
ARG SCYLLARIDAE_URL="https://github.com/islandora/scyllaridae/archive/refs/heads/${SCYLLARIDAE_VERSION}.tar.gz"
ARG SCYLLARIDAE_SHA256="464dd5b2611b97aa116bc01c00cb06019d70d1dd0e55b579a557954ad6ad87a4"
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

RUN create-service-user.sh --name scyllaridae && \
    cleanup.sh

ENV \
  SCYLLARIDAE_ALLOW_INSECURE_ARGS="false" \
  SCYLLARIDAE_LOG_LEVEL=INFO \
  SCYLLARIDAE_PORT=8080 \
  SCYLLARIDAE_YML_PATH="/app/scyllaridae.yml"

COPY --link rootfs /
