# syntax=docker/dockerfile:1.5.1
FROM base

ARG TARGETARCH
ARG SCYLLARIDAE_VERSION=3.1.0
ARG SCYLLARIDAE_URL="https://github.com/lehigh-university-libraries/scyllaridae/releases/download/${SCYLLARIDAE_VERSION}/"
ARG SCYLLARIDAE_AMD64_SHA256="4009ecfcafed81f62ae07a583be7da134212e822d2addc428b84247e4a56575e"
ARG SCYLLARIDAE_ARM64_SHA256="ecad3ba9e9851d41b96c384a5ce44998ebbf6580c215ade0c423813ab1db0756"

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
  SCYLLARIDAE_YML_PATH=/app/scyllaridae.yml \
  JWKS_URI=https://islandora.dev/oauth/discovery/keys \
  SKIP_JWT_VERIFY="true" \
  LOG_LEVEL=info

COPY --link rootfs /
