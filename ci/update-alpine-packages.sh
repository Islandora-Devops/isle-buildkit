#!/bin/bash

# Alpine package version updater for Dockerfiles
# Usage: ./update-alpine-packages.sh <old_version> <new_version> [directory]
# Example: ./update-alpine-packages.sh alpine_3_20 alpine_3_22 .

set -euo pipefail

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
    
    # Query Repology API for the specific package
    local url="https://repology.org/api/v1/project/${package_name}"
    
    # Get package info from Repology API with better error handling and User-Agent
    local response
    local http_code
    response=$(curl -s --max-time 15 -H "User-Agent: alpine-updater/1.0 (https://github.com/user/alpine-updater)" -w "%{http_code}" "$url" 2>/dev/null || true)
    
    if [[ -z "$response" ]]; then
        return 1
    fi
    
    # Extract HTTP code from end of response
    http_code="${response: -3}"
    response="${response%???}"
    
    if [[ "$http_code" != "200" ]]; then
        return 1
    fi
    
    # Extract version for the specific Alpine repository using jq
    # Use origversion (the actual package version) instead of version (upstream version)
    local version
    version=$(echo "$response" | jq -r --arg repo "$alpine_version" '.[] | select(.repo == $repo) | .origversion // .version' 2>/dev/null | head -n1)
    
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
        if [[ "$line" =~ renovate:.*depName=${old_alpine}/ ]]; then
            # Extract package name using sed for better compatibility
            local package_name
            package_name=$(echo "$line" | sed -n "s/.*depName=${old_alpine}\/\([^[:space:]]*\).*/\1/p" || true)
            
            if [[ -n "$package_name" ]]; then
                print_status "  Found package: $package_name"
                
                # Update the depName
                local updated_line
                updated_line=$(echo "$line" | sed "s/depName=${old_alpine}\//depName=${new_alpine}\//g")
                
                # Try to get new version
                print_status "  Fetching version for $package_name..."
                local new_version=""
                if new_version=$(get_alpine_package_version "$package_name" "$new_alpine"); then
                    print_status "  Found version: $new_version"
                    
                    # Look for the next line that should contain the version ARG
                    echo "$updated_line" >> "$temp_file"
                    
                    # Read the next line (should be the ARG line)
                    if IFS= read -r next_line; then
                        if [[ "$next_line" =~ ^[[:space:]]*[A-Z_]+_VERSION= ]]; then
                            local var_name
                            var_name=$(echo "$next_line" | sed -n 's/^[[:space:]]*\([A-Z_]*_VERSION\)=.*/\1/p')
                            local updated_version_line="  ${var_name}=${new_version} \\"
                            
                            if [[ "$dry_run" == "true" ]]; then
                                print_status "  [DRY RUN] Would update: $var_name=$new_version"
                            else
                                echo "$updated_version_line" >> "$temp_file"
                                changes_made=true
                                print_status "  Updated: $var_name=$new_version"
                            fi
                        else
                            echo "$next_line" >> "$temp_file"
                        fi
                    fi
                else
                    print_warning "  Could not fetch version for $package_name, keeping comment update only"
                    echo "$updated_line" >> "$temp_file"
                    changes_made=true
                fi
                continue
            fi
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
    
    # Clean up backup if no changes were made
    if [[ "$dry_run" != "true" && "$changes_made" != "true" && -f "${dockerfile}.backup" ]]; then
        rm -f "${dockerfile}.backup"
    fi
}

# Main function
main() {
    local old_alpine=""
    local new_alpine=""
    local directory="."
    local dry_run="false"
    
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
            *)
                if [[ -z "$old_alpine" ]]; then
                    old_alpine="$1"
                elif [[ -z "$new_alpine" ]]; then
                    new_alpine="$1"
                elif [[ -z "$directory" || "$directory" == "." ]]; then
                    directory="$1"
                else
                    print_error "Too many arguments"
                    usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate arguments
    if [[ -z "$old_alpine" || -z "$new_alpine" ]]; then
        print_error "Missing required arguments"
        usage
        exit 1
    fi
    
    if [[ ! -d "$directory" ]]; then
        print_error "Directory not found: $directory"
        exit 1
    fi
    
    print_status "Starting Alpine package update process"
    print_status "Old version: $old_alpine"
    print_status "New version: $new_alpine"
    print_status "Directory: $directory"
    
    if [[ "$dry_run" == "true" ]]; then
        print_warning "DRY RUN MODE - No files will be modified"
    fi
    
    # Find all Dockerfiles
    local dockerfile_count=0
    while IFS= read -r -d '' dockerfile; do
        update_dockerfile "$dockerfile" "$old_alpine" "$new_alpine" "$dry_run"
        ((dockerfile_count++))
    done < <(find "$directory" -name "Dockerfile*" -type f -print0)
    
    if [[ $dockerfile_count -eq 0 ]]; then
        print_warning "No Dockerfiles found in $directory"
    else
        print_status "Processed $dockerfile_count Dockerfile(s)"
        
        if [[ "$dry_run" != "true" ]]; then
            print_status "Backup files created with .backup extension"
            print_status "To restore: find $directory -name '*.backup' -exec sh -c 'mv \"\$1\" \"\${1%.backup}\"' _ {} \;"
        fi
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

