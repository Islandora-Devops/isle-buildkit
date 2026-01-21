#!/usr/bin/env bash
set -euo pipefail

# Remove apk OS package pinning from all dockerfiles
# This allows rebuilding old tags with the latest
# OS packages available in the base image's package manager.
#
# Usage: ./ci/build-with-os-versions.sh <tag>
#   tag    - The git tag to build from (must exist)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly ROOT_DIR

usage() {
    echo "Usage: $0 <tag>"
    echo ""
    echo "Arguments:"
    echo "  tag     - The git tag to build from (must exist)"
    echo ""
    echo "Examples:"
    echo "  $0 1.0.0        # Build all images locally with tag 1.0.0"
    exit 1
}
if [[ $# -lt 1 ]]; then
    usage
fi

TAG="${1}"

# Verify the git tag exists before proceeding
git fetch origin tag "${TAG}"
git checkout "${TAG}"

# Determine images directory (old tags use root, newer tags use ./images)
if [[ -d "${ROOT_DIR}/images" ]]; then
    IMAGES_DIR="${ROOT_DIR}/images"
else
    IMAGES_DIR="${ROOT_DIR}"
fi

# Remove OS package version pinning from Dockerfiles
echo "==> Removing OS package version pinning from Dockerfiles..."
for dockerfile in "${IMAGES_DIR}"/*/Dockerfile; do
    if [[ ! -f "${dockerfile}" ]]; then
        continue
    fi
    sed -i.bak 's/==[^ ]*//g' "${dockerfile}"
    rm "${dockerfile}.bak"
done
