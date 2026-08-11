#!/usr/bin/env bash

set -euo pipefail

# Alpine bump script: replicates what Renovate does for our Alpine pins in
# one pass, for both routine self-updates and minor migrations.
#   1. Resolves the latest patch release on Docker Hub for the target minor
#      (the currently pinned minor for a self-update, or an explicit minor
#      when migrating) and updates ALPINE_CONTEXT's tag+digest in
#      docker-bake.hcl to match.
#   2. Hands the old and new `alpine_3_XX` release labels to
#      update-alpine-packages.sh, which refreshes every
#      `renovate: datasource=repology depName=alpine_3_XX/...` package pin in
#      images/*/Dockerfile against the new release. Passing the same label
#      twice (old == new) is what makes this a self-update instead of a
#      migration - update-alpine-packages.sh already treats that as "refresh
#      in place", so there's no separate self-update code path to maintain.
#
# Usage: ./update-alpine.sh [<new_minor>] [directory]
# Examples:
#   ./update-alpine.sh                 # self-update: latest patch of the pinned minor
#   ./update-alpine.sh images          # same, explicit directory
#   ./update-alpine.sh 3.25            # migrate to the latest 3.25.x patch
#   ./update-alpine.sh 3.25 images     # same, explicit directory

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status()  { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BAKE_FILE="${REPO_ROOT}/docker-bake.hcl"

# Bump ALPINE_CONTEXT in docker-bake.hcl to the newest patch release of
# $target_minor (defaults to whatever minor is currently pinned). Echoes the
# release label (e.g. alpine_3_25) for the resulting pin on stdout.
update_alpine_context() {
    local target_minor="$1"
    local current_tag current_minor latest_tag latest_digest

    current_tag=$(sed -nE 's#.*ALPINE_CONTEXT[[:space:]]*=[[:space:]]*"docker-image://alpine:([0-9]+\.[0-9]+\.[0-9]+)@.*#\1#p' "$BAKE_FILE")
    if [[ -z "$current_tag" ]]; then
        print_error "Could not find ALPINE_CONTEXT in $BAKE_FILE"
        exit 1
    fi
    current_minor="${current_tag%.*}"
    target_minor="${target_minor:-$current_minor}"

    print_status "Checking alpine:${target_minor}.x tags on Docker Hub..." >&2

    latest_tag=$(curl -fsSL "https://hub.docker.com/v2/repositories/library/alpine/tags?name=${target_minor}&page_size=100" |
        jq -r --arg minor "$target_minor" \
            '.results[] | select(.name | test("^" + $minor + "\\.[0-9]+$")) | .name' |
        sort -t. -k3 -n | tail -n1)

    if [[ -z "$latest_tag" ]]; then
        print_error "Could not resolve any alpine:${target_minor}.x tag on Docker Hub"
        exit 1
    fi

    if [[ "$latest_tag" == "$current_tag" ]]; then
        print_status "ALPINE_CONTEXT already up to date (alpine:${current_tag})" >&2
    else
        latest_digest=$(curl -fsSL "https://hub.docker.com/v2/repositories/library/alpine/tags/${latest_tag}" | jq -r '.digest')
        if [[ -z "$latest_digest" || "$latest_digest" == "null" ]]; then
            print_error "Could not resolve digest for alpine:${latest_tag}"
            exit 1
        fi

        print_status "Updating ALPINE_CONTEXT: alpine:${current_tag} -> alpine:${latest_tag}" >&2
        sed -i.bak -E "s#docker-image://alpine:[0-9]+\.[0-9]+\.[0-9]+@sha256:[0-9a-f]+#docker-image://alpine:${latest_tag}@${latest_digest}#" "$BAKE_FILE"
        rm -f "${BAKE_FILE}.bak"
    fi

    echo "alpine_$(echo "$current_minor" | tr '.' '_') alpine_$(echo "$target_minor" | tr '.' '_')"
}

main() {
    local target_minor="" directory="images"

    case $# in
        0) ;;
        1)
            if [[ -d "$1" ]]; then directory="$1"; else target_minor="$1"; fi
            ;;
        2)
            target_minor="$1"
            directory="$2"
            ;;
        *)
            print_error "Too many arguments"
            print_error "Usage: $0 [<new_minor>] [directory]"
            exit 1
            ;;
    esac

    if [[ ! -d "$directory" ]]; then
        print_error "Directory not found: $directory"
        exit 1
    fi

    local old_label new_label
    read -r old_label new_label < <(update_alpine_context "$target_minor")

    if [[ "$old_label" == "$new_label" ]]; then
        print_status "Self-updating apk package pins for ${new_label} in ${directory}..."
    else
        print_status "Migrating apk package pins ${old_label} -> ${new_label} in ${directory}..."
    fi
    "${SCRIPT_DIR}/update-alpine-packages.sh" "$old_label" "$new_label" "$directory"
}

main "$@"
