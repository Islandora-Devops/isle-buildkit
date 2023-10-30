#!/usr/bin/env bash
set -euo pipefail

ARGS=("$@")
PROGNAME=$(basename "$0")
readonly ARGS PROGNAME

function usage {
    cat <<-EOF
    usage: $PROGNAME options

    Downloads the file at the given url to the download cache folder.

    Does not re-download the file it already exists and matches the given checksum.

    Unpacks the file if the destination option is given.

    Download is placed in the directory ${DOWNLOAD_CACHE_DIRECTORY}.

    OPTIONS:
       -u --url           The url of the file to download.
       -c --sha256        The sha256 checksum to use to validate the download.
       -d --dest          The location to unpack file into (optional).
       -s --strip         Exclude the root folder when unpacking (optional, not supported with gzip or jar).
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       $PROGNAME  \\
        --url https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz
        --sha256 7f3aba1d803543dd1df3944d014f055112cf8dadf0a583c76dd5f46578ebe3c2 \\
        --dest /opt/s6-overlay
EOF
}

function cmdline {
    local arg=
    local args=
    for arg; do
        local delim=""
        case "$arg" in
        # Translate --gnu-long-options to -g (short options)
        --url) args="${args}-u " ;;
        --sha256) args="${args}-c " ;;
        --dest) args="${args}-d " ;;
        --strip) args="${args}-s " ;;
        --help) args="${args}-h " ;;
        --debug) args="${args}-x " ;;
        # Pass through anything else
        *)
            [[ "${arg:0:1}" == "-" ]] || delim="\""
            args="${args}${delim}${arg}${delim} "
            ;;
        esac
    done

    # Reset the positional parameters to the short options
    eval set -- "${args}"

    while getopts "u:c:d:shx" OPTION; do
        case $OPTION in
        u)
            readonly URL=${OPTARG}
            ;;
        c)
            readonly CHECKSUM=${OPTARG}
            ;;
        d)
            readonly DEST=${OPTARG}
            ;;
        s)
            readonly STRIP=true
            ;;
        h)
            usage
            exit 0
            ;;
        x)
            set -x
            ;;
        *)
            echo "Invalid Option: $OPTION" >&2
            usage
            exit 1
            ;;
        esac
    done

    if [[ -z $URL || -z $CHECKSUM ]]; then
        echo "Missing one or more required options: --url --sha256"
        exit 1
    fi

    # All remaning parameters are files to be removed from the installation.
    shift $((OPTIND-1))
    readonly REMOVE=("$@")

    return 0
}

function validate {
    local file=${1}
    sha256sum "${file}" | cut -f1 -d' ' | xargs test "${CHECKSUM}" ==
}

function unpack {
    local file="${1}"
    local dest="${2}"
    local args=()
    local filename=
    mkdir -p "${dest}"
    if [[ -v STRIP ]]; then
        args+=("--strip-components" "1")
    fi
    filename=$(basename "${file}")
    case "${file}" in
    *.tar.xz | *.txz)
        tar -xf "${file}" -C "${dest}" "${args[@]}"
        ;;
    *.tar.gz | *.tgz)
        tar -xzf "${file}" -C "${dest}" "${args[@]}"
        ;;
    *.gz | *.gzip)
        gunzip "${file}" -f -c > "${dest}/${filename%.*}"
        ;;
    *.zip | *.war)
        if [[ -v STRIP ]]; then
            mkdir -p /tmp/unpack
            unzip "${file}" -d /tmp/unpack
            mv "$(find /tmp/unpack/ -type d -mindepth 1 -maxdepth 1)"/* "${dest}"
            rm -fr /tmp/unpack
        else
            unzip "${file}" -d "${dest}"
        fi
        ;;
    *.jar)
        cp "${file}" "${dest}"
        ;;
    *)
        echo "Unable to unpack ${file} please update script to support additional formats." >&2
        exit 1
        ;;
    esac
    # Remove extraneous files.
    for i in "${REMOVE[@]}"; do
        rm -fr "${dest:?}/${i}"
    done
}

function main {
    local file
    cmdline "${ARGS[@]}"

    file="${DOWNLOAD_CACHE_DIRECTORY:?}/$(basename "${URL}")"
    # Remove the downloaded file if it exist and does not match the checksum so that it can be downloaded again.
    if [ -f "${file}" ] && ! validate "${file}"; then
        rm "${file}"
    fi
    wget -N -P "${DOWNLOAD_CACHE_DIRECTORY}" "${URL}"
    # Return non-zero if the checksum does not match the downloaded file.
    validate "${file}"
    if [[ -v DEST ]]; then
        unpack "${file}" "${DEST}"
    fi
}
main
