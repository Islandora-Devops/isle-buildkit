# syntax=docker/dockerfile:1.5.1
FROM base

ARG TARGETARCH
ARG SCYLLARIDAE_VERSION=4.1.0
ARG SCYLLARIDAE_URL="https://github.com/lehigh-university-libraries/scyllaridae/releases/download/${SCYLLARIDAE_VERSION}/"
ARG SCYLLARIDAE_AMD64_SHA256="e744962ee448c4dcca039b00403d3189c9b2225aead31a61bf91510a77b47d9c"
ARG SCYLLARIDAE_ARM64_SHA256="aa0850f4fffcbafe32b0c7fd8d0b6df3774a2d5c2e1080cd8f7e1556057cb873"

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

RUN create-service-user.sh --name scyllaridae && \
    cleanup.sh

ENV \
  JWKS_URI=https://islandora.dev/oauth/discovery/keys \
  SKIP_JWT_VERIFY="true" \
  LOG_LEVEL=info

COPY --link rootfs /
