#!/usr/bin/env bash

set -euo pipefail

# Alpine package version updater for Dockerfiles
# Usage: ./update-alpine-packages.sh <old_version> <new_version> [directory]
# Example: ./update-alpine-packages.sh alpine_3_20 alpine_3_22 .

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_processing() {
    echo -e "${BLUE}[PROCESSING]${NC} $1"
}

# Function to show usage
usage() {
    echo "Usage: $0 <old_alpine_version> <new_alpine_version> [directory]"
    echo ""
    echo "Examples:"
    echo "  $0 alpine_3_20 alpine_3_22"
    echo "  $0 alpine_3_20 alpine_3_22 ./dockerfiles"
    echo "  $0 alpine_3_22 alpine_3_23 /path/to/dockerfiles"
    echo ""
    echo "This script will:"
    echo "1. Find all Dockerfiles in the specified directory (current dir if not specified)"
    echo "2. Update renovate comments from old Alpine version to new version"
    echo "3. Fetch latest package versions from Alpine package database"
    echo "4. Update version numbers in ARG declarations"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be changed without making modifications"
    echo "  --help       Show this help message"
}

# Function to get package version from Repology API
get_alpine_package_version() {
    local package_name="$1"
    local alpine_version="$2"

    # Repology's project name frequently differs from the Alpine binary package
    # name (e.g. yq-go, mysql-client, procps-ng all live under different project
    # names), so querying /api/v1/project/<pkg> directly returns an empty result
    # for those. Instead resolve the binary package name to its project via the
    # project-by tool, exactly like Renovate's repology datasource does.
    local url="https://repology.org/tools/project-by?repo=${alpine_version}&name_type=binname&target_page=api_v1_project&name=${package_name}"

    # Get package info from Repology API with better error handling and User-Agent.
    # -L follows the project-by redirect through to the api_v1_project response.
    local response
    local http_code
    response=$(curl -sL --max-time 20 -H "User-Agent: alpine-updater/1.0 (https://github.com/user/alpine-updater)" -w "%{http_code}" "$url" 2>/dev/null || true)

    if [[ -z "$response" ]]; then
        return 1
    fi

    # Extract HTTP code from end of response
    http_code="${response: -3}"
    response="${response%???}"

    # An unresolved package returns HTTP 400 with an HTML error page.
    if [[ "$http_code" != "200" ]]; then
        return 1
    fi

    # Match the package within the requested Alpine repo by binary/source/visible
    # name (the project may bundle several), and prefer origversion (the real
    # package revision) over version (the upstream version).
    local version
    version=$(echo "$response" | jq -r --arg repo "$alpine_version" --arg pkg "$package_name" \
        '.[] | select(.repo == $repo) | select(.binname == $pkg or .srcname == $pkg or .visiblename == $pkg) | .origversion // .version' \
        2>/dev/null | head -n1)

    if [[ -n "$version" && "$version" != "null" && "$version" != "" ]]; then
        echo "$version"
        return 0
    else
        return 1
    fi
}

# Function to update a single Dockerfile
update_dockerfile() {
    local dockerfile="$1"
    local old_alpine="$2"
    local new_alpine="$3"
    local dry_run="$4"

    print_processing "Processing $dockerfile"

    if [[ ! -f "$dockerfile" ]]; then
        print_error "File not found: $dockerfile"
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)
    local changes_made=false

    # Process the file line by line
    while IFS= read -r line; do
        # Match a renovate comment pinning an Alpine package, capturing the
        # Alpine release and package name from the depName itself.
        if [[ "$line" =~ renovate:.*depName=(alpine_[0-9_]+)/([^[:space:]]+) ]]; then
            local line_alpine="${BASH_REMATCH[1]}"
            local package_name="${BASH_REMATCH[2]}"

            # Migration mode: only touch comments for the requested old release,
            # leave any others untouched. In-place mode ($old_alpine empty)
            # refreshes every Alpine package against its current release.
            if [[ -n "$old_alpine" && "$line_alpine" != "$old_alpine" ]]; then
                echo "$line" >> "$temp_file"
                continue
            fi

            # The release to look up against and to write into the depName:
            # the new release when migrating, otherwise the line's own release.
            local target_alpine="${new_alpine:-$line_alpine}"

            print_status "  Found package: $package_name ($line_alpine)"

            # Rewrite the depName to the target release (no-op when unchanged).
            local updated_line
            updated_line=$(echo "$line" | sed "s/depName=${line_alpine}\//depName=${target_alpine}\//g")
            if [[ "$updated_line" != "$line" ]]; then
                changes_made=true
            fi

            # Try to get the latest version for the target release.
            print_status "  Fetching version for $package_name..."
            local new_version=""
            if new_version=$(get_alpine_package_version "$package_name" "$target_alpine"); then
                echo "$updated_line" >> "$temp_file"

                # Read the next line (should be the ARG version assignment).
                if IFS= read -r next_line; then
                    if [[ "$next_line" =~ ^[[:space:]]*([A-Z_]+_VERSION)=([^[:space:]\\]*) ]]; then
                        local var_name="${BASH_REMATCH[1]}"
                        local current_version="${BASH_REMATCH[2]}"
                        local updated_version_line="  ${var_name}=${new_version} \\"

                        if [[ "$new_version" == "$current_version" ]]; then
                            print_status "  $var_name already up to date ($current_version)"
                            echo "$next_line" >> "$temp_file"
                        elif [[ "$dry_run" == "true" ]]; then
                            print_status "  [DRY RUN] Would update: $var_name $current_version -> $new_version"
                            echo "$next_line" >> "$temp_file"
                        else
                            echo "$updated_version_line" >> "$temp_file"
                            changes_made=true
                            print_status "  Updated: $var_name $current_version -> $new_version"
                        fi
                    else
                        echo "$next_line" >> "$temp_file"
                    fi
                fi
            else
                print_warning "  Could not fetch version for $package_name, keeping comment as-is"
                echo "$updated_line" >> "$temp_file"
            fi
            continue
        fi

        echo "$line" >> "$temp_file"
    done < "$dockerfile"

    # Apply changes if not dry run
    if [[ "$dry_run" != "true" && "$changes_made" == "true" ]]; then
        mv "$temp_file" "$dockerfile"
        print_status "Updated $dockerfile"
    else
        rm -f "$temp_file"
        if [[ "$dry_run" == "true" ]]; then
            print_status "[DRY RUN] Would update $dockerfile"
        else
            print_warning "No changes made to $dockerfile"
        fi
    fi
}

# Main function
main() {
    local old_alpine=""
    local new_alpine=""
    local directory="."
    local dry_run="false"
    local positional=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                dry_run="true"
                shift
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done

    # Interpret positional arguments. Versions are optional: when none are
    # given the script runs in "check for updates" mode, refreshing every
    # package against the Alpine release already pinned in its depName.
    #   (no versions)        -> in-place update, directory "."
    #   <dir>                -> in-place update of <dir>
    #   <old> <new>          -> migrate releases, directory "."
    #   <old> <new> <dir>    -> migrate releases in <dir>
    case ${#positional[@]} in
        0)
            ;;
        1)
            if [[ -d "${positional[0]}" ]]; then
                directory="${positional[0]}"
            else
                print_error "Single argument must be a directory for in-place updates, or pass <old> <new> [dir] to migrate releases"
                usage
                exit 1
            fi
            ;;
        2)
            old_alpine="${positional[0]}"
            new_alpine="${positional[1]}"
            ;;
        3)
            old_alpine="${positional[0]}"
            new_alpine="${positional[1]}"
            directory="${positional[2]}"
            ;;
        *)
            print_error "Too many arguments"
            usage
            exit 1
            ;;
    esac

    if [[ ! -d "$directory" ]]; then
        print_error "Directory not found: $directory"
        exit 1
    fi

    if [[ -n "$old_alpine" ]]; then
        print_status "Starting Alpine package update process"
        print_status "Old version: $old_alpine"
        print_status "New version: $new_alpine"
    else
        print_status "Checking for Alpine package updates (in-place)"
    fi
    print_status "Directory: $directory"

    if [[ "$dry_run" == "true" ]]; then
        print_warning "DRY RUN MODE - No files will be modified"
    fi

    # Find all Dockerfiles
    local dockerfile_count=0
    while IFS= read -r -d '' dockerfile; do
        update_dockerfile "$dockerfile" "$old_alpine" "$new_alpine" "$dry_run"
        dockerfile_count=$((dockerfile_count + 1))
    done < <(find "$directory" -name "Dockerfile*" -type f -print0)

    if [[ $dockerfile_count -eq 0 ]]; then
        print_warning "No Dockerfiles found in $directory"
    else
        print_status "Processed $dockerfile_count Dockerfile(s)"
    fi
}

# Setup macOS compatibility
setup_macos_compatibility() {
    # Minimal setup - jq is now required so no special handling needed
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Running on macOS"
    fi
}

# Check dependencies
check_dependencies() {
    local missing_deps=()

    if ! command -v curl >/dev/null 2>&1; then
        missing_deps+=("curl")
    fi

    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi

    if ! command -v sed >/dev/null 2>&1; then
        missing_deps+=("sed")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_error "Please install the missing tools:"
        print_error "  macOS: brew install ${missing_deps[*]}"
        print_error "  Ubuntu/Debian: apt install ${missing_deps[*]}"
        print_error "  RHEL/CentOS/Fedora: yum install ${missing_deps[*]} (or dnf install)"
        exit 1
    fi
}

# Run dependency check and setup compatibility
check_dependencies
setup_macos_compatibility

# Run main function
main "$@"
