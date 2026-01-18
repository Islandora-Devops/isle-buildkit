#!/command/with-contenv bash
# shellcheck shell=bash
set -e

# Keys are provided via a confd and placed in "/opt/keys/handle"
function convert_key {
    local in=${1}
    shift
    local out=${1}
    shift
    s6-setuidgid handle /opt/handle/bin/hdl-convert-key "/opt/keys/handle/${in}" -o "/var/handle/${out}"
}

# Convert keys from PEM to DES bin files
convert_key "private.key" "privkey.bin"
convert_key "public.key" "pubkey.bin"
convert_key "admin.private.key" "admpriv.bin"
convert_key "admin.public.key" "admpub.bin"

# Derive HANDLE_PUBLICKEY_BASE64 from the pubkey.bin file.
s6-env -i HANDLE_PUBLICKEY_BASE64="$(openssl base64 -A </var/handle/pubkey.bin)" s6-dumpenv -- /var/run/s6/container_environment

# The HANDLE_PUBLICKEY_BASE64 is referenced in confd templates so we must re-render them.
/command/with-contenv confd-render-templates.sh -- -onetime -sync-only
