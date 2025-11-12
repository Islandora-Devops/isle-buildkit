FROM golang:1.25-alpine3.22@sha256:d3f0cf7723f3429e3f9ed846243970b20a2de7bae6a5b66fc5914e228d831bbb AS builder

ARG TARGETARCH
# renovate: datasource=github-releases depName=scyllaridae packageName=islandora/scyllaridae
ARG SCYLLARIDAE_VERSION=5.1.0
ARG SCYLLARIDAE_URL="https://github.com/islandora/scyllaridae/archive/refs/tags/${SCYLLARIDAE_VERSION}.tar.gz"
ARG SCYLLARIDAE_SHA256="2fd7fc31133435e39b0ffb777a260777dadfad63cdbfc88bc50bf2d00b052016"

WORKDIR /build

RUN apk add --no-cache curl tar && \
    download.sh \
      --url "${SCYLLARIDAE_URL}" \
      --sha256 "${SCYLLARIDAE_SHA256}" \
      --dest .

RUN go build -o scyllaridae -ldflags="-s -w" .

FROM base

ARG TARGETARCH

COPY --from=builder /build/scyllaridae /app/scyllaridae

RUN create-service-user.sh --name scyllaridae && \
    cleanup.sh

ENV \
  SCYLLARIDAE_LOG_LEVEL=INFO \
  SCYLLARIDAE_PORT=8080 \
  SCYLLARIDAE_YML_PATH="/app/scyllaridae.yml"

COPY --link rootfs /
