#!/usr/bin/env bash
set -euo pipefail
# Scan all tags on the repo
# foreach tag, see if all our base docker images exist for that tag
# If a tag is missing, kick off a github action workflow to rebuild those tags
#
# Usage: ./ci/backfill-tags.sh [OPTIONS]
#
# Options:
#   --yolo              Execute the workflow runs (default: dry-run mode)
#   --tag TAG           Process only a specific tag instead of all tags
#
# Examples:
#   ./ci/backfill-tags.sh                                # Dry-run all tags
#   ./ci/backfill-tags.sh --yolo                    # Execute workflow runs for all tags (one workflow at a time)
#   ./ci/backfill-tags.sh --tag 3.0.0            # Dry-run specific tag
#   ./ci/backfill-tags.sh --yolo --tag 4.1.3 # Execute workflow for specific tag
# Handle Ctrl+C
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT TERM

# Docker images to check for each semver tag
DOCKER_IMAGES=(
  activemq
  alpaca
  blazegraph
  cantaloupe
  crayfish
  crayfits
  drupal
  fcrepo6
  fits
  handle
  homarus
  houdini
  hypercube
  imagemagick
  java
  mariadb
  milliner
  nginx
  postgresql
  riprap
  solr
  tomcat
)

DOCKER_REPOSITORY="${DOCKER_REPOSITORY:-islandora}"
WORKFLOW_FILE="${WORKFLOW_FILE:-push.yml}"
WORKFLOW_REF="${WORKFLOW_REF:-main}"
LOG_FILE="${LOG_FILE:-backfill-tags.log}"
DRY_RUN=true
SINGLE_TAG=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --yolo)
      DRY_RUN=false
      shift
      ;;
    --tag)
      SINGLE_TAG="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Get all semver tags from the repo (3.x and above), sorted
get_semver_tags() {
  git tag --list | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | while read -r tag; do
    # Extract major version (strip leading 'v' if present)
    local version="${tag#v}"
    local major="${version%%.*}"
    if [[ "$major" -ge 3 ]]; then
      echo "$tag"
    fi
  done
}

# Get the workflow file for a given tag
get_workflow_file() {
  local tag="$1"
  local version="${tag#v}"
  local major="${version%%.*}"

  if [[ "$major" -le 5 ]]; then
    echo "push-backfill.yml"
  else
    echo "$WORKFLOW_FILE"
  fi
}

# Check if a Docker image exists
image_exists() {
  local image="$1"
  local tag="$2"
  local full_image="${DOCKER_REPOSITORY}/${image}:${tag}"

  # Use docker manifest inspect to check if image exists (doesn't pull the image)
  if docker manifest inspect "$full_image" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

# Log a workflow run
log_workflow() {
  local tag="$1"
  local run_id="$2"
  local url="$3"
  local timestamp
  timestamp=$(date -Iseconds)

  echo "${timestamp} | ${tag} | ${run_id} | ${url}" >> "$LOG_FILE"
  echo "  Logged to $LOG_FILE: $url"
}

# Run the workflow for a given tag
run_workflow() {
  local tag="$1"
  local workflow
  workflow=$(get_workflow_file "$tag")

  echo "Running workflow $workflow for tag: $tag"

  if [[ "$DRY_RUN" == "true" ]]; then
    if [[ "$workflow" == "push-backfill.yml" ]]; then
      echo "[DRY-RUN] Would run: gh workflow run $workflow --ref $WORKFLOW_REF -f tag=$tag"
    else
      echo "[DRY-RUN] Would run: gh workflow run $workflow --ref $WORKFLOW_REF -f tag=$tag -f strip-apk-pinning=true"
    fi
    return 0
  fi

  # Run the workflow and wait for completion
  if [[ "$workflow" == "push-backfill.yml" ]]; then
    gh workflow run "$workflow" \
      --ref "$WORKFLOW_REF" \
      -f "tag=$tag"
  else
    gh workflow run "$workflow" \
      --ref "$WORKFLOW_REF" \
      -f "tag=$tag" \
      -f "strip-apk-pinning=true"
  fi

  # Give GitHub a moment to register the run
  sleep 5

  # Get the run ID and URL of the workflow we just triggered
  local run_info run_id run_url
  run_info=$(gh run list --workflow="$workflow" --limit=1 --json databaseId,url --jq '.[0] | "\(.databaseId) \(.url)"')
  run_id=$(echo "$run_info" | cut -d' ' -f1)
  run_url=$(echo "$run_info" | cut -d' ' -f2)

  # Log the tag and workflow URL
  log_workflow "$tag" "$run_id" "$run_url"

  echo "Waiting for workflow run $run_id to complete..."
  while true; do
    status=$(gh run view "$run_id" --json status,conclusion --jq '.status')
    if [[ "$status" == "completed" ]]; then
      conclusion=$(gh run view "$run_id" --json conclusion --jq '.conclusion')
      if [[ "$conclusion" != "success" ]]; then
        echo "  Workflow failed with conclusion: $conclusion"
        exit 1
      fi
      break
    fi
    printf "."
    sleep 30
  done
  echo ""

  echo "Workflow completed for tag: $tag"
}

# Main logic
main() {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "=== DRY-RUN MODE (pass --yolo to execute) ==="
    echo ""
  fi

  local tags
  if [[ -n "$SINGLE_TAG" ]]; then
    tags="$SINGLE_TAG"
    echo "Processing single tag: $tags"
  else
    tags=$(get_semver_tags)

    if [[ -z "$tags" ]]; then
      echo "No semver tags >= 3.0.0 found in repository"
      exit 0
    fi

    echo "Found semver tags (>= 3.0.0):"
    echo "$tags"
  fi
  echo ""

  while IFS= read -r tag; do
    echo "Checking tag: $tag"

    local missing_images=()

    for image in "${DOCKER_IMAGES[@]}"; do
      if ! image_exists "$image" "$tag"; then
        missing_images+=("$image")
      fi
    done

    if [[ ${#missing_images[@]} -gt 0 ]]; then
      echo "  Missing images for $tag: ${missing_images[*]}"
      run_workflow "$tag"
    else
      echo "  All images exist for $tag, skipping"
    fi

    echo ""
  done <<< "$tags"

  echo "Done!"
}

main
