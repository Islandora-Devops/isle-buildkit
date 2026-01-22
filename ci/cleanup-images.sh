#!/usr/bin/env bash

# Container Image Cleanup Script
# Deletes image versions older than 90 days, excluding 'main' and semver tags
# Supports multiple registries via registry-specific implementation scripts

set -eou pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default to dry run mode for safety
DRY_RUN="true"
REGISTRY=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration (can be overridden by environment)
DAYS_OLD="${DAYS_OLD:-90}"

# Semver regex pattern (matches tags like v1.2.3, 1.2.3, 5, 5.10, v2.1-alpha, etc.)
SEMVER_PATTERN='^v?[0-9]+(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9\.]+)?$'

# Usage function
usage() {
    echo "Usage: $0 --registry <ghcr|dockerhub> [--yolo]"
    echo ""
    echo "Options:"
    echo "  --registry <type> - Registry type: ghcr or dockerhub (required)"
    echo "  --yolo            - Actually perform deletions (default is dry run)"
    echo "  -h, --help        - Show this help message"
    echo ""
    echo "Environment variables (common):"
    echo "  DAYS_OLD          - Age threshold in days (default: 90)"
    echo ""

    # Show registry-specific help if available
    if [ -n "$REGISTRY" ] && type registry_usage &>/dev/null; then
        echo "Registry-specific environment variables ($REGISTRY):"
        registry_usage
    else
        echo "Registry-specific environment variables:"
        echo "  Run with --registry <type> --help for registry-specific options"
    fi

    echo ""
    echo "Example (dry run):"
    echo "  $0 --registry ghcr"
    echo ""
    echo "Example (actual deletion):"
    echo "  $0 --registry ghcr --yolo"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --registry)
            REGISTRY="$2"
            shift 2
            ;;
        --yolo)
            DRY_RUN="false"
            shift
            ;;
        -h|--help)
            # Try to load registry for help if specified
            if [ -n "$REGISTRY" ] && [ -f "$SCRIPT_DIR/cleanup-$REGISTRY.sh" ]; then
                # shellcheck disable=SC1090
                source "$SCRIPT_DIR/cleanup-$REGISTRY.sh"
            fi
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate registry
if [ -z "$REGISTRY" ]; then
    echo -e "${RED}Error: --registry is required${NC}"
    usage
fi

REGISTRY_SCRIPT="$SCRIPT_DIR/cleanup-$REGISTRY.sh"
if [ ! -f "$REGISTRY_SCRIPT" ]; then
    echo -e "${RED}Error: Unknown registry '$REGISTRY'. Supported: ghcr, dockerhub${NC}"
    exit 1
fi

# shellcheck disable=SC1090
source "$REGISTRY_SCRIPT"

# Validate registry-specific configuration
registry_validate_config

# Calculate cutoff date
CUTOFF_DATE=$(date -d "$DAYS_OLD days ago" -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -v-"${DAYS_OLD}"d -u +"%Y-%m-%dT%H:%M:%SZ")

echo -e "${GREEN}Container Image Cleanup Script${NC}"
echo "================================"
registry_print_config
echo "Deleting versions older than: $CUTOFF_DATE ($DAYS_OLD days)"
echo "Preserving: 'main' tag and version tags (e.g., 5, 5.10, 1.2.3), excluding arch-specific tags (e.g., 5.1.5-arm64)"
if [ "$DRY_RUN" = "true" ]; then
    echo -e "Mode: ${YELLOW}DRY RUN${NC} (no deletions will occur)"
else
    echo -e "Mode: ${RED}LIVE${NC} (deletions will be performed)"
fi
echo ""

# Function to check if a tag has an architecture suffix (should not be preserved)
is_arch_tag() {
    local tag="$1"
    [[ "$tag" =~ -(arm64|amd64)$ ]]
}

# Function to check if a tag is semver (and not an arch-specific tag)
is_semver() {
    local tag="$1"
    # Arch-specific tags like 5.1.5-arm64 should not be preserved
    if is_arch_tag "$tag"; then
        return 1
    fi
    [[ "$tag" =~ $SEMVER_PATTERN ]]
}

# Function to compare dates
is_older_than_cutoff() {
    local updated_at="$1"
    if [[ "$updated_at" < "$CUTOFF_DATE" ]]; then
        return 0
    else
        return 1
    fi
}

# Fetch all versions
echo "Fetching all versions..."
ALL_VERSIONS=$(registry_fetch_all_versions)

# Build a list of digests from preserved versions (main and semver tags)
echo "Identifying preserved versions and their dependencies..."
PRESERVED_DIGESTS=$(registry_get_preserved_digests "$ALL_VERSIONS")

PRESERVED_COUNT_DIGESTS=$(echo "$PRESERVED_DIGESTS" | grep -c . || echo "0")
echo "Found $PRESERVED_COUNT_DIGESTS preserved digests"
echo ""

# Create temp files for counters (to avoid subshell issues)
TEMP_DIR=$(mktemp -d)
cleanup_temp() {
    rm -rf "$TEMP_DIR"
}
trap cleanup_temp EXIT

echo "0" > "$TEMP_DIR/deleted"
echo "0" > "$TEMP_DIR/preserved"
echo "0" > "$TEMP_DIR/errors"

# Process versions for deletion
echo "Processing versions..."
TOTAL_VERSIONS=$(echo "$ALL_VERSIONS" | jq 'length')
echo "Total versions to process: $TOTAL_VERSIONS"
echo ""

CURRENT=0
while read -r version; do
    CURRENT=$((CURRENT + 1))

    VERSION_ID=$(registry_get_version_id "$version")
    UPDATED_AT=$(registry_get_version_date "$version")
    VERSION_DIGEST=$(registry_get_version_digest "$version")
    TAGS=$(registry_get_version_tags "$version")

    # Default to untagged if no tags
    if [ -z "$TAGS" ]; then
        TAG_DISPLAY="<untagged>"
        SHOULD_DELETE=true

        # Check if this untagged version is a preserved digest (referenced by a kept tag)
        if echo "$PRESERVED_DIGESTS" | grep -qF "$VERSION_DIGEST"; then
            SHOULD_DELETE=false
            echo -e "${YELLOW}[$CURRENT/$TOTAL_VERSIONS] Preserving${NC} version $VERSION_ID (digest: ${VERSION_DIGEST:0:20}...) - referenced by preserved tag"
            echo $(($(cat "$TEMP_DIR/preserved") + 1)) > "$TEMP_DIR/preserved"
        fi
    else
        TAG_DISPLAY="$TAGS"
        SHOULD_DELETE=true

        # Check each tag
        for tag in $TAGS; do
            # Preserve 'main' tag
            if [ "$tag" = "main" ]; then
                SHOULD_DELETE=false
                echo -e "${YELLOW}[$CURRENT/$TOTAL_VERSIONS] Preserving${NC} version $VERSION_ID (tag: $tag) - main tag"
                echo $(($(cat "$TEMP_DIR/preserved") + 1)) > "$TEMP_DIR/preserved"
                break
            fi

            # Preserve semver tags (including partial versions)
            if is_semver "$tag"; then
                SHOULD_DELETE=false
                echo -e "${YELLOW}[$CURRENT/$TOTAL_VERSIONS] Preserving${NC} version $VERSION_ID (tag: $tag) - version tag"
                echo $(($(cat "$TEMP_DIR/preserved") + 1)) > "$TEMP_DIR/preserved"
                break
            fi
        done
    fi

    # Check if old enough and should delete
    if [ "$SHOULD_DELETE" = true ] && is_older_than_cutoff "$UPDATED_AT"; then
        if [ "$DRY_RUN" = "true" ]; then
            echo -e "${YELLOW}[$CURRENT/$TOTAL_VERSIONS] [DRY RUN]${NC} Would delete version $VERSION_ID (tags: $TAG_DISPLAY, updated: $UPDATED_AT)"
            echo $(($(cat "$TEMP_DIR/deleted") + 1)) > "$TEMP_DIR/deleted"
        else
            echo -e "${RED}[$CURRENT/$TOTAL_VERSIONS] Deleting${NC} version $VERSION_ID (tags: $TAG_DISPLAY, updated: $UPDATED_AT)"
            if registry_delete_version "$VERSION_ID"; then
                echo $(($(cat "$TEMP_DIR/deleted") + 1)) > "$TEMP_DIR/deleted"
            else
                echo -e "${RED}Failed to delete version $VERSION_ID${NC}"
                echo $(($(cat "$TEMP_DIR/errors") + 1)) > "$TEMP_DIR/errors"
            fi
        fi
    elif [ "$SHOULD_DELETE" = true ]; then
        echo -e "${GREEN}[$CURRENT/$TOTAL_VERSIONS] Keeping${NC} version $VERSION_ID (tags: $TAG_DISPLAY, updated: $UPDATED_AT) - too recent"
    fi
done < <(echo "$ALL_VERSIONS" | jq -c '.[]')

# Read final counts
DELETED_COUNT=$(cat "$TEMP_DIR/deleted")
PRESERVED_COUNT=$(cat "$TEMP_DIR/preserved")
ERROR_COUNT=$(cat "$TEMP_DIR/errors")

echo ""
echo "================================"
echo "Summary:"
echo "  Versions deleted: $DELETED_COUNT"
echo "  Versions preserved: $PRESERVED_COUNT"
echo "  Errors: $ERROR_COUNT"

if [ "$DRY_RUN" = "true" ]; then
    echo ""
    echo -e "${YELLOW}This was a dry run. Run with --yolo to perform actual deletions.${NC}"
fi
