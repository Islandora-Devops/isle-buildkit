FROM base AS builder

WORKDIR /build

ARG TARGETARCH

# renovate: datasource=github-releases depName=scyllaridae packageName=islandora/scyllaridae
ARG SCYLLARIDAE_VERSION=5.2.0
ARG SCYLLARIDAE_URL="https://github.com/islandora/scyllaridae/archive/refs/tags/${SCYLLARIDAE_VERSION}.tar.gz"
ARG SCYLLARIDAE_SHA256="66314e94d3dd6c306ba1b1f143ce8a9168fd9f0f9aa49339e48d8c8aaf66d145"
RUN download.sh \
      --url "${SCYLLARIDAE_URL}" \
      --sha256 "${SCYLLARIDAE_SHA256}" \
      --dest .

FROM base

COPY --from=builder /build/scyllaridae /app/scyllaridae

ARG \
    # renovate: datasource=repology depName=alpine_3_23/go
    GO_VERSION=1.25.5-r0 \
    # renovate: datasource=repology depName=alpine_3_23/mailcap
    MAILCAP_VERSION=2.1.54-r0 \

RUN --mount=type=cache,id=scyllaridae-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
      go=="${GO_VERSION}" \
      mailcap=="${MAILCAP_VERSION}" && \
    create-service-user.sh --name scyllaridae && \
    cleanup.sh

ENV \
  SCYLLARIDAE_ALLOW_INSECURE_ARGS="false" \
  SCYLLARIDAE_LOG_LEVEL=INFO \
  SCYLLARIDAE_PORT=8080 \
  SCYLLARIDAE_YML_PATH="/app/scyllaridae.yml"

COPY --link rootfs /
