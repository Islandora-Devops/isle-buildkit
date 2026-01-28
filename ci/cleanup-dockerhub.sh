#!/usr/bin/env bash

# Docker Hub implementation for cleanup-images.sh
# This script is sourced by cleanup-images.sh and provides registry-specific functions

# Configuration
DOCKERHUB_USERNAME="${REGISTRY_USER:-}"
DOCKERHUB_TOKEN="${REGISTRY_PASSWORD:-}"
DOCKERHUB_NAMESPACE="${DOCKERHUB_NAMESPACE:-islandora}"
DOCKERHUB_REPOSITORY="${DOCKERHUB_REPOSITORY:-}"
DOCKERHUB_API_BASE="https://hub.docker.com/v2"
DOCKERHUB_JWT=""

# Registry-specific usage
registry_usage() {
    echo "  REGISTRY_USER       - Docker Hub username"
    echo "  REGISTRY_PASSWORD   - Docker Hub personal access token (PAT)"
    echo "  DOCKERHUB_NAMESPACE - Docker Hub namespace (default: islandora)"
    echo "  DOCKERHUB_REPOSITORY - Repository name to clean up"
}

# Authenticate with Docker Hub and get JWT
dockerhub_authenticate() {
    local response
    response=$(curl -s -X POST "$DOCKERHUB_API_BASE/users/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"$DOCKERHUB_USERNAME\", \"password\": \"$DOCKERHUB_TOKEN\"}")

    DOCKERHUB_JWT=$(echo "$response" | jq -r '.token // empty')

    if [ -z "$DOCKERHUB_JWT" ]; then
        echo -e "${RED}Error: Failed to authenticate with Docker Hub${NC}" >&2
        echo "$response" | jq -r '.message // .detail // .' >&2
        exit 1
    fi
}

# Validate required configuration
registry_validate_config() {
    if [ -z "$DOCKERHUB_USERNAME" ]; then
        echo -e "${RED}Error: REGISTRY_USER is not set${NC}"
        exit 1
    fi

    if [ -z "$DOCKERHUB_TOKEN" ]; then
        echo -e "${RED}Error: REGISTRY_PASSWORD is not set${NC}"
        exit 1
    fi

    if [ -z "$DOCKERHUB_REPOSITORY" ]; then
        echo -e "${RED}Error: DOCKERHUB_REPOSITORY is not set${NC}"
        exit 1
    fi

    # Authenticate to get JWT
    echo "Authenticating with Docker Hub..."
    dockerhub_authenticate
    echo "Authentication successful."
    echo ""
}

# Print registry-specific configuration
registry_print_config() {
    echo "Registry: Docker Hub"
    echo "Namespace: $DOCKERHUB_NAMESPACE"
    echo "Repository: $DOCKERHUB_REPOSITORY"
}

# Fetch all versions (tags) from Docker Hub
registry_fetch_all_versions() {
    local page=1
    local all_versions="[]"

    while true; do
        local response
        response=$(curl -s -H "Authorization: Bearer $DOCKERHUB_JWT" \
            "$DOCKERHUB_API_BASE/repositories/$DOCKERHUB_NAMESPACE/$DOCKERHUB_REPOSITORY/tags?page_size=100&page=$page")

        # Check for API errors
        if echo "$response" | jq -e '.message or .detail' > /dev/null 2>&1; then
            local error_msg
            error_msg=$(echo "$response" | jq -r '.message // .detail // "Unknown error"')
            if [ "$error_msg" != "null" ] && [ -n "$error_msg" ]; then
                echo -e "${RED}API Error: $error_msg${NC}" >&2
                exit 1
            fi
        fi

        # Get results array
        local results
        results=$(echo "$response" | jq '.results // []')
        local results_length
        results_length=$(echo "$results" | jq 'length')

        if [ "$results_length" -eq 0 ]; then
            break
        fi

        # Append to array
        all_versions=$(jq -s 'add' <(echo "$all_versions") <(echo "$results"))

        # Check if there's a next page
        local next
        next=$(echo "$response" | jq -r '.next // empty')
        if [ -z "$next" ]; then
            break
        fi

        page=$((page + 1))

        # Safety: break after reasonable max pages
        if [ "$page" -gt 100 ]; then
            echo -e "${YELLOW}Warning: Reached 100 pages (10,000 tags). Stopping pagination.${NC}" >&2
            break
        fi
    done

    echo "$all_versions"
}

# Get preserved digests (main and semver tags, excluding arch-specific tags)
# For Docker Hub, we use the tag name as the "digest" for consistency
registry_get_preserved_digests() {
    local all_versions="$1"
    echo "$all_versions" | jq -r '
        .[] |
        select(
            (.name == "main") or
            (
                (.name | test("^v?[0-9]+(\\.[0-9]+)?(\\.[0-9]+)?(-[a-zA-Z0-9\\.]+)?$")) and
                (.name | test("-(arm64|amd64)$") | not)
            )
        ) |
        .name
    ' | sort -u
}

# Get version ID (for Docker Hub, this is the tag name)
registry_get_version_id() {
    local version="$1"
    echo "$version" | jq -r '.name'
}

# Get version date
registry_get_version_date() {
    local version="$1"
    echo "$version" | jq -r '.last_updated // .tag_last_pushed // empty'
}

# Get version digest/name
registry_get_version_digest() {
    local version="$1"
    # Use the digest if available, otherwise the tag name
    echo "$version" | jq -r '.digest // .name // empty'
}

# Get version tags (for Docker Hub, each entry is a single tag)
registry_get_version_tags() {
    local version="$1"
    echo "$version" | jq -r '.name // empty'
}

# Delete a version (tag) from Docker Hub
registry_delete_version() {
    local tag_name="$1"
    local response
    response=$(curl -s -w "%{http_code}" -o /tmp/dockerhub_delete_response.txt \
        -X DELETE \
        -H "Authorization: Bearer $DOCKERHUB_JWT" \
        "$DOCKERHUB_API_BASE/repositories/$DOCKERHUB_NAMESPACE/$DOCKERHUB_REPOSITORY/tags/$tag_name")

    if [ "$response" -eq 204 ] || [ "$response" -eq 200 ]; then
        return 0
    else
        cat /tmp/dockerhub_delete_response.txt >&2
        return 1
    fi
}
