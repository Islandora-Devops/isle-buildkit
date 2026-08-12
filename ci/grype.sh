#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?usage: ci/grype.sh <image> <image-ref-or-digest-output>}"
IMAGE_REF="${2:?usage: ci/grype.sh <image> <image-ref-or-digest-output>}"

case "${IMAGE_REF}" in
  -Pisle.*.digest=*)
    IMAGE_REF="${IMAGE_REF#*=}"
    ;;
esac

REPORT_DIR="build/${IMAGE}"
SBOM="${REPORT_DIR}/sbom.json"
REPORT="${REPORT_DIR}/${IMAGE}-grype.md"

mkdir -p "${REPORT_DIR}"

docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  anchore/syft:latest \
  "${IMAGE_REF}" \
  -o json > "${SBOM}"

docker run --rm \
  -v "${PWD}/grype.yaml:/grype.yaml:ro" \
  -v "${PWD}/${REPORT_DIR}:/work:ro" \
  anchore/grype:latest \
  --config /grype.yaml \
  --output table \
  "sbom:/work/sbom.json" > "${REPORT}"
