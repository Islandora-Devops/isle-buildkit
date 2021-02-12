#!/usr/bin/env bash
set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

function usage {
    cat <<- EOF
    usage: $PROGNAME options

    Attempts to fetch the given keys from one of the GPG key-servers.
    Exits non-zero if not successful.

    If no server is given a default list of servers is used.

    OPTIONS:
       --key              The key to fetch (list).
       --server           The server to use for fetching keys (list).
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Fetch the key:
       $PROGNAME \\
                --key 2536CA16DF4FCDA2 \\
                --key 814E346FA01A20DBB04B6807B5DBD5925590A237 \\
                --server hkp://pool.sks-keyservers.net \\
                --server pgp.mit.edu
EOF
}

function cmdline {
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            # Translate --gnu-long-options to -g (short options)
            --key)         args="${args}-k ";;
            --server)      args="${args}-s ";;
            --help)        args="${args}-h ";;
            --debug)       args="${args}-x ";;
            # Pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
               args="${args}${delim}${arg}${delim} ";;
        esac
    done

    # Reset the positional parameters to the short options
    eval set -- $args

    local keys=()
    local servers=()
    while getopts "k:s:hx" OPTION
    do
        case $OPTION in
        k)
            keys+=("$OPTARG")
            ;;
        s)
            servers+=("$OPTARG")
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

    if [[ -z "${keys[@]}" ]]; then
        echo "Missing one of required options: --keys" >&2
        exit 1
    fi

    readonly KEYS=("${keys[@]}")

    if [[ -z "${servers[@]}" ]]; then
        # Defaults if none specified.
        readonly SERVERS=(
            ha.pool.sks-keyservers.net
            keyserver.pgp.com
            pgp.mit.edu
            pool.sks-keyservers.net
        )
    else
        readonly SERVERS=("${servers[@]}")
    fi

    return 0
}

function receive_keys {
    local failed=0
    local num_servers="${#SERVERS[@]}"
    for key in "${KEYS[@]}"; do
        failed=0
        for server in "${SERVERS[@]}"; do
            gpg --keyserver "${server}" --recv-keys "${key}" && break || true
            ((failed+=1))
        done
        if [ $num_servers -eq $failed ]; then
            exit 1
        fi
    done
}

function main {
    cmdline ${ARGS}
    receive_keys
}
main
