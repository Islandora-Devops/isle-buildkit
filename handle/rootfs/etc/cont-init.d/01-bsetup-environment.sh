#!/usr/bin/with-contenv bash
set -e

HANDLE_SRV_HOME=/var/handle

# Convert keys from string to DES bin file inside handle
$(printf %s "${HANDLE_PRIVATE_KEY_PEM}" | /opt/handle/bin/hdl-convert-key -o "${HANDLE_SRV_HOME}/privkey.bin")
$(printf %s "${HANDLE_PUBLIC_KEY_PEM}" | /opt/handle/bin/hdl-convert-key -o "${HANDLE_SRV_HOME}/pubkey.bin")
$(printf %s "${HANDLE_ADMIN_PRIVATE_KEY_PEM}" | /opt/handle/bin/hdl-convert-key -o "${HANDLE_SRV_HOME}/admpriv.bin")
$(printf %s "${HANDLE_ADMIN_PUBLIC_KEY_PEM}" | /opt/handle/bin/hdl-convert-key -o "${HANDLE_SRV_HOME}/admpub.bin")

HANDLE_PUBLICKEY_BASE64=$(openssl base64 -A < "${HANDLE_SRV_HOME}/pubkey.bin")
printf "${HANDLE_PUBLICKEY_BASE64}" > /var/run/s6/container_environment/HANDLE_PUBLICKEY_BASE64
