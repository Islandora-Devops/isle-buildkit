#!/usr/bin/env bash
set -e

ARGS=("$@")
PROGNAME=$(basename "$0")
readonly ARGS PROGNAME

function usage() {
    cat <<-EOF
    usage: $PROGNAME

    Import environment variables from confd into the 'container environment',
    i.e. accessible via with-contenv.

    Reads a confd template file from stdin. Renders the file and then imports it
    into the container environment with s6-env and s6-dumpenv.

    The file passed via stdin should render to a set of key/values repesenting a
    set of environment variables and their values.

    OPTIONS:
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       Import the environment variable FOO_BAR from confd:
       echo 'FOO_BAR="{{ getv "/foo/bar" }}"' | $PROGNAME
EOF
}

function cmdline() {
    local arg=
    for arg; do
        local delim=""
        case "$arg" in
        # Translate --gnu-long-options to -g (short options)
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

    while getopts "hx" OPTION; do
        case $OPTION in
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

    return 0
}

function main {
    local tmp_dir
    cmdline "${ARGS[@]}"

    # Temporary directory to deposit generated confd configuration templates and
    # output, etc.
    tmp_dir="$(mktemp -d -t confd-XXXXXXXXXX)"
    mkdir -p "${tmp_dir}/conf.d" "${tmp_dir}/templates" "${tmp_dir}/out"

    # Generate template script that will update the container environment with
    # values provided by the confd backend. execline is used rather than bash
    # to avoid issues with whitespace newlines and string interpolation.
    echo 's6-env -i' >"${tmp_dir}/templates/import.sh.tmpl"
    cat - >>"${tmp_dir}/templates/import.sh.tmpl"
    echo 's6-dumpenv -- /var/run/s6/container_environment' >>"${tmp_dir}/templates/import.sh.tmpl"

    # Temporary confd template config.
    cat <<EOF >>"${tmp_dir}/conf.d/import.sh.toml"
[template]
src = "import.sh.tmpl"
dest = "${tmp_dir}/import.sh"
keys = ["/"]
EOF

    # Temporary confd config.
    cat <<EOF >"${tmp_dir}/confd.toml"
confdir = "${tmp_dir}"
noop = false
prefix = "/"
EOF

    # Generate script to import environment variables from confd.
    with-contenv confd-render-templates.sh -- -onetime -sync-only -config-file "${tmp_dir}/confd.toml"

    # Import the variables from confd.
    execlineb -P "${tmp_dir}/import.sh"

    # Remove temporary files.
    rm -fr "${tmp_dir}"
}
main
