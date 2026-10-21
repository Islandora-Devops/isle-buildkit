#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/ci" "$tmp/images/nginx/build" "$tmp/bin"
cp "$root/ci/update-php.sh" "$tmp/ci/"
cp "$root/images/nginx/build/APKBUILD" "$tmp/images/nginx/build/"
cp "$root/images/nginx/Dockerfile" "$tmp/images/nginx/"
cat > "$tmp/bin/curl" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
for arg in "$@"; do
    if [[ "$arg" == *releases/index.php* ]]; then
        sum=$(printf archive | sha256sum | cut -d ' ' -f1)
        [[ "${BAD_CHECKSUM:-0}" == 0 ]] || sum=$(printf wrong | sha256sum | cut -d ' ' -f1)
        printf '{"source":[{"filename":"php-8.4.99.tar.xz","sha256":"%s"}]}' "$sum"
        exit
    fi
done
printf archive > "${@: -1}"
MOCK
chmod +x "$tmp/bin/curl"
export PATH="$tmp/bin:$PATH"
bash "$tmp/ci/update-php.sh" 8.4.99
grep -q '^pkgver=8.4.99$' "$tmp/images/nginx/build/APKBUILD"
grep -q 'PHP_VERSION=8.4.99-r0' "$tmp/images/nginx/Dockerfile"
sum=$(printf archive | sha512sum | cut -d ' ' -f1)
grep -q "^$sum  php-8.4.99.tar.xz$" "$tmp/images/nginx/build/APKBUILD"
cp "$tmp/images/nginx/build/APKBUILD" "$tmp/before"
if BAD_CHECKSUM=1 bash "$tmp/ci/update-php.sh" 8.4.99; then exit 1; fi
cmp "$tmp/before" "$tmp/images/nginx/build/APKBUILD"
if bash "$tmp/ci/update-php.sh" 8.5.0; then exit 1; fi
echo 'PHP updater checks passed'
