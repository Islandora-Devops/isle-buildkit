#!/usr/bin/env bash

set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME DEST
 
    Downloads the file at the given url checking it against the given sha256. 
    If checksum matches return 0 otherwise delete the downloaded file and return non-zero.

    Download is placed in the directory DEST.

    OPTIONS:
       -u --url           The url of the file to download.
       -c --sha256        The sha256 checksum to use to validate the download.
       -h --help          Show this help.
       -x --debug         Debug this script.
 
    Examples:
       $PROGNAME  https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz 7f3aba1d803543dd1df3944d014f055112cf8dadf0a583c76dd5f46578ebe3c2 /opt/downloads
EOF
}

function cmdline {
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            # Translate --gnu-long-options to -g (short options)
            --url)        args="${args}-u ";;
            --sha256)     args="${args}-c ";;
            --help)       args="${args}-h ";;
            --debug)      args="${args}-x ";;
            # Pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done
 
    # Reset the positional parameters to the short options
    eval set -- $args
 
    while getopts "u:c:hx" OPTION
    do
        case $OPTION in
        u)
            readonly URL=${OPTARG}
            ;;
        c)
            readonly CHECKSUM=${OPTARG}
            ;;
        h)
            usage
            exit 0
            ;;
        x)
            readonly DEBUG='-x'
            set -x
            ;;
        esac
    done

    if [[ -z $URL || -z $CHECKSUM ]]; then
        echo "Missing one or more required options: --url --sha256"
        exit 1
    fi

    # The only parameters is the destination directory.
    shift $((OPTIND-1))

    if [ "$#" -ne 1 ]; then
      echo "Illegal number of parameters"
      usage
      return 1
    fi

    readonly DEST="${1}"

    return 0
}


function validate {
    local file=${1}
    sha256sum "${file}" | cut -f1 -d' ' | xargs test "${CHECKSUM}" == 
}

function main {
    cmdline ${ARGS}
    local file="${DEST}/$(basename ${URL})"
    # Remove the downloaded file if it exist and does not match the checksum so that it can be downloaded again.
    if [ -f "${file}" ] && ! validate "${file}"; then
        rm "${file}"
    fi
    wget -N -P "${DEST}" "${URL}"
    # Return non-zero if the checksum doesn't match the downloaded file.
    validate "${file}"
}
main