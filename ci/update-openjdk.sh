#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
recipe=images/java/build/APKBUILD
tag=${1:-$(sed -n 's/^# upstream-tag=//p' "$recipe")}
[[ "$tag" =~ ^jdk-(21\.[0-9]+\.[0-9]+(\.[0-9]+)?)(\+[0-9]+|-ga)$ ]] || {
    echo 'Expected an OpenJDK 21 update tag, e.g. jdk-21.0.13.1-ga' >&2
    exit 1
}
version=${BASH_REMATCH[1]}
source_version=${tag#jdk-}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL --connect-timeout 10 --max-time 180 --retry 3 \
    "https://github.com/openjdk/jdk21u/archive/$tag.tar.gz" -o "$tmp/jdk.tar.gz"
if [[ "$tag" == *-ga ]]; then
    # GA archives omit the build number. Resolve the matching numbered tag.
    refs=$(git ls-remote --tags https://github.com/openjdk/jdk21u.git \
        "refs/tags/$tag" "refs/tags/$tag^{}" "refs/tags/jdk-$version+*")
    commit=$(awk -v tag="refs/tags/$tag" '$2 == tag {sha=$1} $2 == tag "^{}" {peeled=$1} END {print peeled ? peeled : sha}' <<< "$refs")
    build=$(awk -v sha="$commit" -v prefix="refs/tags/jdk-$version+" \
        '$1 == sha && index($2, prefix) == 1 {sub(/\^\{\}$/, "", $2); sub(/^.*\+/, "", $2); print $2}' <<< "$refs" | sort -n | tail -1)
else
    build=${tag##*+}
fi
[[ "$build" =~ ^[0-9]+$ ]] || { echo 'Missing upstream build number' >&2; exit 1; }
sum=$(sha512sum "$tmp/jdk.tar.gz" | cut -d ' ' -f1)
sed -i -E \
    -e "s/^# upstream-tag=.*/# upstream-tag=$tag/" \
    -e "s/^pkgver=.*/pkgver=${version}_p$build/" \
    -e "s/^_pkgver=.*/_pkgver=$source_version/" \
    -e 's/^pkgrel=.*/pkgrel=0/' \
    -e "s/^[a-f0-9]{128}  jdk-.*\.tar\.gz$/$sum  jdk-$source_version.tar.gz/" \
    "$recipe"
sed -i -E "s/OPENJDK_VERSION=[^ ]+/OPENJDK_VERSION=${version}_p$build-r0/" images/java/Dockerfile
