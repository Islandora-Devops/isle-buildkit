#!/usr/bin/env bash

# GitHub Container Registry (GHCR) implementation for cleanup-images.sh
# This script is sourced by cleanup-images.sh and provides registry-specific functions

# Configuration
GHCR_ORG_OR_USER="${GITHUB_ORG:-${GITHUB_USER:-}}"
GHCR_PACKAGE_TYPE="${PACKAGE_TYPE:-container}"
GHCR_TOKEN="${GITHUB_TOKEN:-}"
GHCR_PACKAGE_NAME="${PACKAGE_NAME:-}"
GHCR_API_BASE="https://api.github.com"

# Registry-specific usage
registry_usage() {
    echo "  GITHUB_TOKEN      - GitHub personal access token with packages:delete scope"
    echo "  PACKAGE_NAME      - Name of the package to clean up"
    echo "  GITHUB_ORG        - GitHub organization name (or use GITHUB_USER for personal)"
    echo ""
    echo "  Optional:"
    echo "  PACKAGE_TYPE      - Package type (default: container)"
    echo "                      Options: container, npm, maven, rubygems, nuget, docker"
}

# Validate required configuration
registry_validate_config() {
    if [ -z "$GHCR_TOKEN" ]; then
        echo -e "${RED}Error: GITHUB_TOKEN is not set${NC}"
        exit 1
    fi

    if [ -z "$GHCR_PACKAGE_NAME" ]; then
        echo -e "${RED}Error: PACKAGE_NAME is not set${NC}"
        exit 1
    fi

    if [ -z "$GHCR_ORG_OR_USER" ]; then
        echo -e "${RED}Error: Either GITHUB_ORG or GITHUB_USER must be set${NC}"
        exit 1
    fi

    # Determine if org or user
    if [ -n "${GITHUB_ORG:-}" ]; then
        GHCR_ENDPOINT_TYPE="orgs"
        GHCR_OWNER="$GITHUB_ORG"
    else
        GHCR_ENDPOINT_TYPE="users"
        GHCR_OWNER="$GITHUB_USER"
    fi
}

# Print registry-specific configuration
registry_print_config() {
    echo "Registry: GitHub Container Registry (GHCR)"
    echo "Owner: $GHCR_OWNER"
    echo "Package: $GHCR_PACKAGE_NAME"
    echo "Type: $GHCR_PACKAGE_TYPE"
}

# Fetch all versions from GHCR
registry_fetch_all_versions() {
    local page=1
    local all_versions=""

    while true; do
        local response
        response=$(curl -s -H "Authorization: Bearer $GHCR_TOKEN" \
            -H "Accept: application/vnd.github+json" \
            "$GHCR_API_BASE/$GHCR_ENDPOINT_TYPE/$GHCR_OWNER/packages/$GHCR_PACKAGE_TYPE/$GHCR_PACKAGE_NAME/versions?per_page=100&page=$page")

        # Check for API errors
        if echo "$response" | jq -e '.message' > /dev/null 2>&1; then
            echo -e "${RED}API Error: $(echo "$response" | jq -r '.message')${NC}" >&2
            exit 1
        fi

        # Check if response is empty array
        local response_length
        response_length=$(echo "$response" | jq 'length')
        if [ "$response_length" -eq 0 ]; then
            break
        fi

        # Append to array
        if [ -z "$all_versions" ]; then
            all_versions="$response"
        else
            all_versions=$(jq -s 'add' <(echo "$all_versions") <(echo "$response"))
        fi

        page=$((page + 1))

        # Safety: break after reasonable max pages
        if [ "$page" -gt 100 ]; then
            echo -e "${YELLOW}Warning: Reached 100 pages (10,000 versions). Stopping pagination.${NC}" >&2
            break
        fi
    done

    # Return combined array
    if [ -z "$all_versions" ]; then
        echo "[]"
    else
        echo "$all_versions" | jq -s 'add'
    fi
}

# Get preserved digests (main and semver tags, excluding arch-specific tags)
registry_get_preserved_digests() {
    local all_versions="$1"
    echo "$all_versions" | jq -r '
        .[] |
        select(
            (.metadata.container.tags[]? == "main") or
            (
                (.metadata.container.tags[]? | test("^v?[0-9]+(\\.[0-9]+)?(\\.[0-9]+)?(-[a-zA-Z0-9\\.]+)?$")) and
                (.metadata.container.tags[]? | test("-(arm64|amd64)$") | not)
            )
        ) |
        .name // empty
    ' | sort -u
}

# Get version ID
registry_get_version_id() {
    local version="$1"
    echo "$version" | jq -r '.id'
}

# Get version date
registry_get_version_date() {
    local version="$1"
    echo "$version" | jq -r '.updated_at'
}

# Get version digest/name
registry_get_version_digest() {
    local version="$1"
    echo "$version" | jq -r '.name // empty'
}

# Get version tags (space-separated)
registry_get_version_tags() {
    local version="$1"
    echo "$version" | jq -r '.metadata.container.tags[]?' 2>/dev/null || echo ""
}

# Delete a version
registry_delete_version() {
    local version_id="$1"
    local response
    response=$(curl -s -w "%{http_code}" -o /tmp/ghcr_delete_response.txt \
        -X DELETE \
        -H "Authorization: Bearer $GHCR_TOKEN" \
        -H "Accept: application/vnd.github+json" \
        "$GHCR_API_BASE/$GHCR_ENDPOINT_TYPE/$GHCR_OWNER/packages/$GHCR_PACKAGE_TYPE/$GHCR_PACKAGE_NAME/versions/$version_id")

    if [ "$response" -eq 204 ] || [ "$response" -eq 200 ]; then
        return 0
    else
        cat /tmp/ghcr_delete_response.txt >&2
        return 1
    fi
}
