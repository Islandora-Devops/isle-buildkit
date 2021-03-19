#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

trap 'cleanup $?' EXIT
function cleanup() {
    # Something has gone wrong remove the cache so subsequent attempts can be made.
    if [[ ${1} -ne 0 ]]; then
        remove_cache
    fi
}

function usage() {
    cat <<-EOF
    usage: $PROGNAME options [FILE]...
 
    Does a git clone utilizing the Buildkit caching mechanism.

    OPTIONS:
       -u --url           The URL of the repository to clone.
       -d --cache-dir     The directory to use as a cache.
       -c --commit        The commit hash or tag to checkout.
       -w --worktree      The directory to checkout the repository into.
       -s --strip         Remove the git repo as well as any files passed as parameters to save space.
       -h --help          Show this help.
       -x --debug         Debug this script.
 
    Examples:
       Clone repository:
       $PROGNAME \\
                --url https://github.com/Islandora-CLAW/Alpaca.git \\
                --cache-dir /opt/downloads \\
                --commit "${COMMIT}" \\
                --worktree /opt/alpaca
EOF
}

function cmdline() {
    local arg=
    for arg; do
        local delim=""
        case "$arg" in
        # Translate --gnu-long-options to -g (short options)
        --url)
            args="${args}-u "
            ;;
        --cache-dir)
            args="${args}-d "
            ;;
        --commit)
            args="${args}-c "
            ;;
        --worktree)
            args="${args}-w "
            ;;
        --strip)
            args="${args}-s "
            ;;
        --help)
            args="${args}-h "
            ;;
        --debug)
            args="${args}-x "
            ;;
        # Pass through anything else
        *)
            [[ "${arg:0:1}" == "-" ]] || delim="\""
            args="${args}${delim}${arg}${delim} "
            ;;
        esac
    done

    # Reset the positional parameters to the short options
    eval set -- $args

    while getopts "u:d:c:w:shx" OPTION; do
        case $OPTION in
        u)
            readonly URL=${OPTARG}
            ;;
        d)
            readonly CACHE_DIRECTORY=${OPTARG}
            ;;
        c)
            readonly COMMIT=${OPTARG}
            ;;
        w)
            readonly WORKTREE=${OPTARG}
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

    readonly REPOSITORY=$(basename ${WORKTREE})

    if [[ -z $URL || -z $CACHE_DIRECTORY || -z $COMMIT || -z $WORKTREE ]]; then
        echo "Missing one or more required options: --url --cache-dir --commit --worktree" >&2
        exit 1
    fi

    # All remaning parameters are files to be removed from the repo if --strip was specified.
    shift $((OPTIND - 1))
    readonly REMOVE=("$@")

    return 0
}

function remove_cache() {
    rm -fr ${CACHE_DIRECTORY}/${REPOSITORY}
    rm -fr ${WORKTREE}
}

function update_cache() {
    git clone --mirror ${URL} ${CACHE_DIRECTORY}/${REPOSITORY} || true
    git clone ${CACHE_DIRECTORY}/${REPOSITORY} ${WORKTREE}
    git -C ${WORKTREE} fetch --all
}

function checkout() {
    git -C ${WORKTREE} reset --hard ${COMMIT}
}

function main() {
    cmdline ${ARGS}
    update_cache
    # Attempt twice in case the history of the cache has become invalid.
    checkout || (remove_cache && update_cache && checkout)
    if [[ -z $STRIP ]]; then
        rm -fr ${WORKTREE}/.git
        for i in "${REMOVE[@]}"; do
            rm -fr "${WORKTREE}/${i}"
        done
    fi
}
main
