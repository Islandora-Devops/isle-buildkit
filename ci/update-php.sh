#!/usr/bin/env bash
set -euo pipefail

# Called by Renovate after updating pkgver, or manually with an 8.4.x version.
cd "$(dirname "$0")/.."
version=${1:-$(sed -n 's/^pkgver=//p' images/nginx/build/APKBUILD)}
[[ "$version" =~ ^8\.4\.[0-9]+$ ]] || { echo 'Expected a stable PHP 8.4.x version' >&2; exit 1; }
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL --connect-timeout 10 --max-time 180 --retry 3 "https://www.php.net/releases/index.php?json&version=$version" > "$tmp/release.json"
sha=$(jq -er --arg file "php-$version.tar.xz" '.source[] | select(.filename == $file) | .sha256' "$tmp/release.json")
[[ "$sha" =~ ^[a-f0-9]{64}$ ]]
curl -fsSL --connect-timeout 10 --max-time 180 --retry 3 "https://www.php.net/distributions/php-$version.tar.xz" -o "$tmp/php.tar.xz"
printf '%s  %s\n' "$sha" "$tmp/php.tar.xz" | sha256sum -c -
sum=$(sha512sum "$tmp/php.tar.xz" | cut -d ' ' -f1)
sed -i -E \
    -e "s/^pkgver=.*/pkgver=$version/" \
    -e 's/^pkgrel=.*/pkgrel=0/' \
    -e "s/^[a-f0-9]{128}  php-[0-9.]+\.tar\.xz$/$sum  php-$version.tar.xz/" \
    images/nginx/build/APKBUILD
sed -i -E "s/PHP_VERSION=[0-9.]+-r[0-9]+/PHP_VERSION=$version-r0/" images/nginx/Dockerfile
