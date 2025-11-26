#!/usr/bin/env bash

# GitHub Package Registry Cleanup Script
# Deletes package versions older than 90 days, excluding 'main' and semver tags

set -eou pipefail

# Configuration
DAYS_OLD=90
ORG_OR_USER="${GITHUB_ORG:-$GITHUB_USER}"
PACKAGE_TYPE="${PACKAGE_TYPE:-container}"  # container, npm, maven, rubygems, nuget, docker
TOKEN="${GITHUB_TOKEN}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Semver regex pattern (matches tags like v1.2.3, 1.2.3, 5, 5.10, v2.1-alpha, etc.)
# Matches: v1.2.3, 1.2.3, v1.2, 1.2, v5, 5, with optional pre-release suffixes
SEMVER_PATTERN='^v?[0-9]+(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9\.]+)?$'

# Usage function
usage() {
    echo "Usage: $0"
    echo ""
    echo "Environment variables required:"
    echo "  GITHUB_TOKEN      - GitHub personal access token with packages:delete scope"
    echo "  PACKAGE_NAME      - Name of the package to clean up"
    echo "  GITHUB_ORG        - GitHub organization name (or use GITHUB_USER for personal)"
    echo ""
    echo "Optional environment variables:"
    echo "  PACKAGE_TYPE      - Package type (default: container)"
    echo "                      Options: container, npm, maven, rubygems, nuget, docker"
    echo "  DAYS_OLD          - Age threshold in days (default: 90)"
    echo "  DRY_RUN           - Set to 'true' to preview without deleting"
    echo ""
    echo "Example:"
    echo "  export GITHUB_TOKEN=ghp_xxxxxxxxxxxx"
    echo "  export GITHUB_ORG=myorg"
    echo "  export PACKAGE_NAME=myapp"
    echo "  export DRY_RUN=true"
    echo "  $0"
    exit 1
}

# Check required variables
if [ -z "$TOKEN" ]; then
    echo -e "${RED}Error: GITHUB_TOKEN is not set${NC}"
    usage
fi

if [ -z "$PACKAGE_NAME" ]; then
    echo -e "${RED}Error: PACKAGE_NAME is not set${NC}"
    usage
fi

if [ -z "$ORG_OR_USER" ]; then
    echo -e "${RED}Error: Either GITHUB_ORG or GITHUB_USER must be set${NC}"
    usage
fi

# Determine if org or user
if [ -n "$GITHUB_ORG" ]; then
    ENDPOINT_TYPE="orgs"
    OWNER="$GITHUB_ORG"
else
    ENDPOINT_TYPE="users"
    OWNER="$GITHUB_USER"
fi

API_BASE="https://api.github.com"
CUTOFF_DATE=$(date -d "$DAYS_OLD days ago" -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -v-${DAYS_OLD}d -u +"%Y-%m-%dT%H:%M:%SZ")

echo -e "${GREEN}GitHub Package Cleanup Script${NC}"
echo "================================"
echo "Owner: $OWNER"
echo "Package: $PACKAGE_NAME"
echo "Type: $PACKAGE_TYPE"
echo "Deleting versions older than: $CUTOFF_DATE ($DAYS_OLD days)"
echo "Preserving: 'main' tag and version tags (e.g., 5, 5.10, 1.2.3)"
echo ""

if [ "$DRY_RUN" = "true" ]; then
    echo -e "${YELLOW}DRY RUN MODE - No deletions will occur${NC}"
    echo ""
fi

# Function to check if a tag is semver
is_semver() {
    local tag="$1"
    if echo "$tag" | grep -qE "$SEMVER_PATTERN"; then
        return 0
    else
        return 1
    fi
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

# Fetch all package versions
echo "Fetching package versions..."
PAGE=1
DELETED_COUNT=0
PRESERVED_COUNT=0
ERROR_COUNT=0
ALL_VERSIONS=""

# First pass: collect all versions
echo "Collecting all package versions..."
while true; do
    RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
        -H "Accept: application/vnd.github+json" \
        "$API_BASE/$ENDPOINT_TYPE/$OWNER/packages/$PACKAGE_TYPE/$PACKAGE_NAME/versions?per_page=100&page=$PAGE")
    
    # Check for API errors first
    if echo "$RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
        echo -e "${RED}API Error: $(echo "$RESPONSE" | jq -r '.message')${NC}"
        exit 1
    fi
    
    # Check if response is empty array
    RESPONSE_LENGTH=$(echo "$RESPONSE" | jq 'length')
    if [ "$RESPONSE_LENGTH" -eq 0 ]; then
        break
    fi
    
    # Append to array
    if [ -z "$ALL_VERSIONS" ]; then
        ALL_VERSIONS="$RESPONSE"
    else
        ALL_VERSIONS=$(jq -s 'add' <(echo "$ALL_VERSIONS") <(echo "$RESPONSE"))
    fi
    
    PAGE=$((PAGE + 1))
    
    # Safety: break after reasonable max pages
    if [ "$PAGE" -gt 100 ]; then
        echo -e "${YELLOW}Warning: Reached 100 pages (10,000 versions). Stopping pagination.${NC}"
        break
    fi
done

# Combine all versions into a single JSON array
ALL_VERSIONS=$(echo "$ALL_VERSIONS" | jq -s 'add')

# Build a list of digests from preserved versions (main and semver tags)
echo "Identifying preserved versions and their dependencies..."
PRESERVED_DIGESTS=$(echo "$ALL_VERSIONS" | jq -r '
    .[] | 
    select(
        (.metadata.container.tags[]? == "main") or 
        (.metadata.container.tags[]? | test("^v?[0-9]+(\\.[0-9]+)?(\\.[0-9]+)?(-[a-zA-Z0-9\\.]+)?$"))
    ) | 
    .name // empty
' | sort -u)

echo "Found $(echo "$PRESERVED_DIGESTS" | grep -c .) preserved digests"
echo ""

# Create temp files for counters (to avoid subshell issues)
TEMP_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "0" > "$TEMP_DIR/deleted"
echo "0" > "$TEMP_DIR/preserved"
echo "0" > "$TEMP_DIR/errors"

# Now process versions for deletion
echo "Processing versions..."
TOTAL_VERSIONS=$(echo "$ALL_VERSIONS" | jq 'length')
echo "Total versions to process: $TOTAL_VERSIONS"
echo ""

CURRENT=0
while read -r version; do
    CURRENT=$((CURRENT + 1))
    
    VERSION_ID=$(echo "$version" | jq -r '.id')
    UPDATED_AT=$(echo "$version" | jq -r '.updated_at')
    VERSION_DIGEST=$(echo "$version" | jq -r '.name // empty')
    TAGS=$(echo "$version" | jq -r '.metadata.container.tags[]?' 2>/dev/null || echo "")
    
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
            DELETE_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/delete_response.txt \
                -X DELETE \
                -H "Authorization: Bearer $TOKEN" \
                -H "Accept: application/vnd.github+json" \
                "$API_BASE/$ENDPOINT_TYPE/$OWNER/packages/$PACKAGE_TYPE/$PACKAGE_NAME/versions/$VERSION_ID")
            
            if [ "$DELETE_RESPONSE" -eq 204 ] || [ "$DELETE_RESPONSE" -eq 200 ]; then
                echo $(($(cat "$TEMP_DIR/deleted") + 1)) > "$TEMP_DIR/deleted"
            else
                echo -e "${RED}Failed to delete version $VERSION_ID (HTTP $DELETE_RESPONSE)${NC}"
                cat /tmp/delete_response.txt
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
    echo -e "${YELLOW}This was a dry run. Set DRY_RUN=false to perform actual deletions.${NC}"
fi
