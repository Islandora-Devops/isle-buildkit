# syntax=docker/dockerfile:1.5.1
FROM base

ARG TARGETARCH
# renovate: datasource=github-releases depName=scyllaridae packageName=islandora/scyllaridae
ARG SCYLLARIDAE_VERSION=5.1.0
ARG SCYLLARIDAE_URL="https://github.com/islandora/scyllaridae/releases/download/${SCYLLARIDAE_VERSION}/"
ARG SCYLLARIDAE_AMD64_SHA256="ed97561fbf1a260509dcc13c7fbbaa21c84d1c71347c01fc46452a167a36bfee"
ARG SCYLLARIDAE_ARM64_SHA256="3b89c14daea56c0b4ebc96b826f291348a97d6a98bddfae0e75ed52ff4050cf9"

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=crayfish-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    SCYLLARIDAE_SHA256=$([ "$TARGETARCH" = "amd64" ] && echo "$SCYLLARIDAE_AMD64_SHA256" || echo "$SCYLLARIDAE_ARM64_SHA256") \
    && SCYLLARIDAE_URL+=$([ "$TARGETARCH" = "amd64" ] && echo "scyllaridae_Linux_x86_64.tar.gz" || echo "scyllaridae_Linux_arm64.tar.gz") \
    && download.sh \
        --url "${SCYLLARIDAE_URL}" \
        --sha256 "${SCYLLARIDAE_SHA256}" \
        --dest "/app" \
    && \
    cleanup.sh

ARG \
  # renovate: datasource=repology depName=alpine_3_22/mailcap
  MAILCAP_VERSION=2.1.54-r0

RUN --mount=type=cache,id=scyllaridae-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add mailcap=="${MAILCAP_VERSION}" && \
    create-service-user.sh --name scyllaridae && \
    cleanup.sh

ENV \
  SCYLLARIDAE_LOG_LEVEL=INFO \
  SCYLLARIDAE_PORT=8080 \
  SCYLLARIDAE_YML_PATH="/app/scyllaridae.yml"

COPY --link rootfs /
