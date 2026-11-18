#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
recipe=images/nginx/nginx-build/APKBUILD
version=${1:-$(sed -n 's/^pkgver=//p' "$recipe")}
[[ "$version" =~ ^1\.30\.[0-9]+$ ]] || { echo 'Expected a stable NGINX 1.30.x version' >&2; exit 1; }
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -m 700 "$tmp/gnupg"
for suffix in tar.gz tar.gz.asc; do
    curl -fsSL --connect-timeout 10 --max-time 180 --retry 3 \
        "https://nginx.org/download/nginx-$version.$suffix" -o "$tmp/nginx.$suffix"
done
gpg --batch --homedir "$tmp/gnupg" --import images/nginx/nginx-build/release-keys.asc
gpg --batch --homedir "$tmp/gnupg" --verify "$tmp/nginx.tar.gz.asc" "$tmp/nginx.tar.gz"
sum=$(sha512sum "$tmp/nginx.tar.gz" | cut -d ' ' -f1)
sed -i -E \
    -e "s/^pkgver=.*/pkgver=$version/" \
    -e 's/^pkgrel=.*/pkgrel=0/' \
    -e "s/^[a-f0-9]{128}  nginx-.*\.tar\.gz$/$sum  nginx-$version.tar.gz/" \
    "$recipe"
sed -i -E "s/NGINX_VERSION=[^ ]+/NGINX_VERSION=$version-r0/" images/nginx/Dockerfile
