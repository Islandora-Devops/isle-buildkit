#!/usr/bin/env bash
set -eou pipefail

SOURCE_EXT="${1,,}"
DEST_EXT="${2,,}"
ARGS=()
if [ "$#" -gt 2 ]; then
  for arg in "${@:3}"; do
    if [ -n "$arg" ]; then
      ARGS+=("$arg")
    fi
  done
fi

THUMBNAIL_SIZE=""
VIPS_ARGS=()
idx=0
while [ "$idx" -lt "${#ARGS[@]}" ]; do
  arg="${ARGS[$idx]}"
  case "$arg" in
    -thumbnail|-resize)
      idx=$((idx + 1))
      if [ "$idx" -ge "${#ARGS[@]}" ]; then
        echo "$arg requires a geometry argument" >&2
        exit 2
      fi
      THUMBNAIL_SIZE="${ARGS[$idx]}"
      ;;
    -strip)
      ;;
    *)
      VIPS_ARGS+=("$arg")
      ;;
  esac
  idx=$((idx + 1))
done

case "$SOURCE_EXT" in
  jpeg) SOURCE_EXT="jpg" ;;
  tif) SOURCE_EXT="tiff" ;;
esac

case "$DEST_EXT" in
  jpeg) DEST_EXT="jpg" ;;
  tif) DEST_EXT="tiff" ;;
esac

WORKDIR=$(mktemp -d /tmp/houdini-XXXXXX)
INPUT="$WORKDIR/input.$SOURCE_EXT"
OUTPUT="$WORKDIR/output.$DEST_EXT"

# shellcheck disable=SC2317
cleanup() {
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

cat > "$INPUT"

LOAD_SPEC="$INPUT"
if [ "$SOURCE_EXT" = "pdf" ]; then
  LOAD_SPEC="${INPUT}[page=0]"
elif [ "$SOURCE_EXT" = "tiff" ]; then
  LOAD_SPEC="${INPUT}[page=0]"
fi

MAX_DIMENSION="${HOUDINI_MAX_DIMENSION:-4096}"
TILE_WIDTH="${HOUDINI_TILE_WIDTH:-512}"
TILE_HEIGHT="${HOUDINI_TILE_HEIGHT:-512}"
JPEG_QUALITY="${HOUDINI_JPEG_QUALITY:-85}"
WEBP_QUALITY="${HOUDINI_WEBP_QUALITY:-85}"
JP2_QUALITY="${HOUDINI_JP2_QUALITY:-85}"

thumbnail_dimension() {
  local geometry="$1"
  geometry="${geometry#\>}"
  geometry="${geometry#\<}"
  geometry="${geometry%!}"
  geometry="${geometry%^}"
  geometry="${geometry%%+*}"
  geometry="${geometry%%-*}"
  if [[ "$geometry" =~ ^([0-9]+)x([0-9]+)$ ]]; then
    if [ "${BASH_REMATCH[1]}" -ge "${BASH_REMATCH[2]}" ]; then
      printf '%s\n' "${BASH_REMATCH[1]}"
    else
      printf '%s\n' "${BASH_REMATCH[2]}"
    fi
    return 0
  fi
  if [[ "$geometry" =~ ^([0-9]+)x$ ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
    return 0
  fi
  if [[ "$geometry" =~ ^x([0-9]+)$ ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
    return 0
  fi
  if [[ "$geometry" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$geometry"
    return 0
  fi
  echo "unsupported thumbnail geometry: $1" >&2
  return 2
}

if [ -n "$THUMBNAIL_SIZE" ]; then
  MAX_DIMENSION=$(thumbnail_dimension "$THUMBNAIL_SIZE")
fi

case "$DEST_EXT" in
  tiff)
    if [ -n "$THUMBNAIL_SIZE" ]; then
      THUMBNAIL="$WORKDIR/thumbnail.tiff"
      vips thumbnail "$LOAD_SPEC" "$THUMBNAIL" "$MAX_DIMENSION" \
        --size down \
        --linear \
        "${VIPS_ARGS[@]}"
      vips tiffsave "$THUMBNAIL" "$OUTPUT" \
        --tile \
        --pyramid \
        --tile-width "$TILE_WIDTH" \
        --tile-height "$TILE_HEIGHT" \
        --compression jpeg \
        --Q "$JPEG_QUALITY" \
        --bigtiff
    else
      vips tiffsave "$LOAD_SPEC" "$OUTPUT" \
        --tile \
        --pyramid \
        --tile-width "$TILE_WIDTH" \
        --tile-height "$TILE_HEIGHT" \
        --compression jpeg \
        --Q "$JPEG_QUALITY" \
        --bigtiff \
        "${VIPS_ARGS[@]}"
    fi
    ;;
  jpg)
    vips thumbnail "$LOAD_SPEC" "${OUTPUT}[Q=$JPEG_QUALITY,optimize-coding=true]" "$MAX_DIMENSION" \
      --size down \
      --linear \
      "${VIPS_ARGS[@]}"
    ;;
  png)
    vips thumbnail "$LOAD_SPEC" "${OUTPUT}[compression=6]" "$MAX_DIMENSION" \
      --size down \
      --linear \
      "${VIPS_ARGS[@]}"
    ;;
  webp)
    vips thumbnail "$LOAD_SPEC" "${OUTPUT}[Q=$WEBP_QUALITY]" "$MAX_DIMENSION" \
      --size down \
      --linear \
      "${VIPS_ARGS[@]}"
    ;;
  jp2)
    if [ -n "$THUMBNAIL_SIZE" ]; then
      THUMBNAIL="$WORKDIR/thumbnail.jp2"
      vips thumbnail "$LOAD_SPEC" "${THUMBNAIL}[Q=$JP2_QUALITY,tile-width=$TILE_WIDTH,tile-height=$TILE_HEIGHT]" "$MAX_DIMENSION" \
        --size down \
        --linear \
        "${VIPS_ARGS[@]}"
      mv "$THUMBNAIL" "$OUTPUT"
    else
      vips copy "$LOAD_SPEC" "${OUTPUT}[Q=$JP2_QUALITY,tile-width=$TILE_WIDTH,tile-height=$TILE_HEIGHT]" \
        "${VIPS_ARGS[@]}"
    fi
    ;;
  *)
    if [ -n "$THUMBNAIL_SIZE" ]; then
      vips thumbnail "$LOAD_SPEC" "$OUTPUT" "$MAX_DIMENSION" \
        --size down \
        --linear \
        "${VIPS_ARGS[@]}"
    else
      vips copy "$LOAD_SPEC" "$OUTPUT" "${VIPS_ARGS[@]}"
    fi
    ;;
esac

# Make sure we have a valid image before returning bytes to Scyllaridae.
timeout 5 vipsheader "$OUTPUT" > /dev/null
cat "$OUTPUT"
