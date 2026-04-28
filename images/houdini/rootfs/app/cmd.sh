#!/usr/bin/env bash
#
# Take an image on stdin, produce a web-friendly copy on stdout.
# Usage: cmd.sh <source-ext> <dest-ext> [imagemagick-style args...]

set -eou pipefail

parse_args() {
  SOURCE_EXT="${1,,}"
  DEST_EXT="${2,,}"
  shift 2 || true

  THUMBNAIL_SIZE=""
  VIPS_ARGS=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      "") ;;
      -strip) ;;
      -thumbnail|-resize)
        shift
        [ "$#" -gt 0 ] || { echo "$1 requires a geometry argument" >&2; exit 2; }
        THUMBNAIL_SIZE="$1"
        ;;
      *) VIPS_ARGS+=("$1") ;;
    esac
    shift
  done
}

normalize_extensions() {
  case "$SOURCE_EXT" in
    jpeg) SOURCE_EXT="jpg" ;;
    tif)  SOURCE_EXT="tiff" ;;
  esac

  case "$DEST_EXT" in
    jpeg) DEST_EXT="jpg" ;;
    tif)  DEST_EXT="tiff" ;;
  esac
}

init_workspace() {
  WORKDIR=$(mktemp -d /tmp/houdini-XXXXXX)
  trap 'rm -rf "$WORKDIR"' EXIT

  INPUT="$WORKDIR/input.$SOURCE_EXT"
  OUTPUT="$WORKDIR/output.$DEST_EXT"

  cat > "$INPUT"
}

init_config() {
  MAX_DIMENSION="${HOUDINI_MAX_DIMENSION:-4096}"
  TILE_WIDTH="${HOUDINI_TILE_WIDTH:-512}"
  TILE_HEIGHT="${HOUDINI_TILE_HEIGHT:-512}"
  JPEG_QUALITY="${HOUDINI_JPEG_QUALITY:-90}"
  WEBP_QUALITY="${HOUDINI_WEBP_QUALITY:-80}"
  JP2_QUALITY="${HOUDINI_JP2_QUALITY:-100}"
  BIGTIFF_MODE="${HOUDINI_BIGTIFF:-auto}"
  BIGTIFF_THRESHOLD_BYTES="${HOUDINI_BIGTIFF_THRESHOLD_BYTES:-3758096384}"  # ~3.5 GiB
  VALIDATE_TIMEOUT="${HOUDINI_VALIDATE_TIMEOUT:-20}"

  # Pyramid TIFFs use JPEG Q=90 by default because libvips disables chroma
  # subsampling at >=90, which avoids edge-tile decode failures on odd-sized
  # pyramid levels in Mac Preview and some IIIF/libtiff readers. Large inputs
  # can still drop to Q=85 to limit derivative size.
  TIFF_JPEG_QUALITY_LARGE="${HOUDINI_TIFF_JPEG_QUALITY_LARGE:-85}"
  TIFF_LARGE_THRESHOLD_BYTES="${HOUDINI_TIFF_LARGE_THRESHOLD_BYTES:-104857600}"  # 100 MiB
}

parse_geometry() {
  local geometry="$1"
  geometry="${geometry#\>}"
  geometry="${geometry#\<}"
  geometry="${geometry%!}"
  geometry="${geometry%^}"
  geometry="${geometry%%+*}"
  geometry="${geometry%%-*}"

  if [[ "$geometry" =~ ^([0-9]+)x([0-9]+)$ ]]; then
    [ "${BASH_REMATCH[1]}" -ge "${BASH_REMATCH[2]}" ] \
      && echo "${BASH_REMATCH[1]}" || echo "${BASH_REMATCH[2]}"
    return 0
  fi

  if [[ "$geometry" =~ ^([0-9]+)x?$ ]] || [[ "$geometry" =~ ^x([0-9]+)$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi

  echo "unsupported thumbnail geometry: $1" >&2
  return 2
}

build_load_spec() {
  LOAD_SPEC="$INPUT"
  case "$SOURCE_EXT" in
    pdf|tiff) LOAD_SPEC="${INPUT}[page=0]" ;;
  esac

  if [ -n "$THUMBNAIL_SIZE" ]; then
    MAX_DIMENSION=$(parse_geometry "$THUMBNAIL_SIZE")
  fi
}

bigtiff_flag() {
  local source="$1"
  case "${BIGTIFF_MODE,,}" in
    1|true|yes|on|always) echo "--bigtiff"; return 0 ;;
    0|false|no|off|never) return 0 ;;
    auto|"") ;;
    *) echo "unsupported HOUDINI_BIGTIFF mode: $BIGTIFF_MODE" >&2; return 2 ;;
  esac

  local width height bands format bytes_per_sample estimated_bytes
  width=$(vipsheader -f width "$source")
  height=$(vipsheader -f height "$source")
  bands=$(vipsheader -f bands "$source")
  format=$(vipsheader -f format "$source")

  case "$format" in
    *uchar*|*char*) bytes_per_sample=1 ;;
    *ushort*|*short*) bytes_per_sample=2 ;;
    *uint*|*int*|*float*) bytes_per_sample=4 ;;
    *dpcomplex*) bytes_per_sample=16 ;;
    *double*|*complex*) bytes_per_sample=8 ;;
    *) bytes_per_sample=1 ;;
  esac

  # Pyramid is base + base/4 + base/16 + ... ~= 4/3 * base
  estimated_bytes=$(( width * height * bands * bytes_per_sample * 4 / 3 ))
  [ "$estimated_bytes" -ge "$BIGTIFF_THRESHOLD_BYTES" ] && echo "--bigtiff"
  return 0
}

tiff_quality() {
  local bytes
  bytes=$(stat -c '%s' "$INPUT" 2>/dev/null || stat -f '%z' "$INPUT" 2>/dev/null || echo 0)
  if [ "$bytes" -gt "$TIFF_LARGE_THRESHOLD_BYTES" ]; then
    echo "houdini: $bytes bytes > $TIFF_LARGE_THRESHOLD_BYTES; using Q=$TIFF_JPEG_QUALITY_LARGE for tiff" >&2
    echo "$TIFF_JPEG_QUALITY_LARGE"
    return 0
  fi

  echo "$JPEG_QUALITY"
}

thumbnail() {
  local output_spec="$1"
  vips thumbnail "$LOAD_SPEC" "$output_spec" "$MAX_DIMENSION" \
    --size down --linear "${VIPS_ARGS[@]}"
}

thumbnail_requested() {
  [ -n "$THUMBNAIL_SIZE" ]
}

thumbnail_source() {
  local thumbnail_output="$WORKDIR/thumbnail.tiff"
  thumbnail "$thumbnail_output"
  echo "$thumbnail_output"
}

write_copy() {
  vips copy "$LOAD_SPEC" "$OUTPUT" "${VIPS_ARGS[@]}"
}

write_copy_or_thumbnail() {
  if thumbnail_requested; then
    thumbnail "$1"
    return 0
  fi

  write_copy
}

write_tiff() {
  local source quality bigtiff compression_args
  source="$LOAD_SPEC"
  if thumbnail_requested; then
    source=$(thumbnail_source)
  fi

  if [ "$SOURCE_EXT" = "jp2" ]; then
    compression_args=(--compression lzw)
  else
    quality=$(tiff_quality)
    compression_args=(--compression jpeg --Q "$quality")
  fi

  bigtiff=$(bigtiff_flag "$source")

  vips tiffsave "$source" "$OUTPUT" \
    --tile --pyramid \
    --tile-width "$TILE_WIDTH" \
    --tile-height "$TILE_HEIGHT" \
    "${compression_args[@]}" \
    ${bigtiff:+$bigtiff} \
    "${VIPS_ARGS[@]}"
}

write_jpg() {
  thumbnail "${OUTPUT}[Q=$JPEG_QUALITY,optimize-coding=true]"
}

write_png() {
  thumbnail "${OUTPUT}[compression=6]"
}

write_webp() {
  thumbnail "${OUTPUT}[Q=$WEBP_QUALITY]"
}

write_jp2() {
  local options
  options="Q=$JP2_QUALITY,tile-width=$TILE_WIDTH,tile-height=$TILE_HEIGHT"
  if thumbnail_requested; then
    thumbnail "${OUTPUT}[$options]"
    return 0
  fi

  vips copy "$LOAD_SPEC" "${OUTPUT}[$options]" "${VIPS_ARGS[@]}"
}

write_output() {
  case "$DEST_EXT" in
    tiff) write_tiff ;;
    jpg) write_jpg ;;
    png) write_png ;;
    webp) write_webp ;;
    jp2) write_jp2 ;;
    *) write_copy_or_thumbnail "$OUTPUT" ;;
  esac
}

validate_output() {
  timeout "$VALIDATE_TIMEOUT" vipsheader "$OUTPUT" > /dev/null
  timeout "$VALIDATE_TIMEOUT" vips avg "$OUTPUT" > /dev/null
}

emit_output() {
  cat "$OUTPUT"
}

main() {
  parse_args "$@"
  normalize_extensions
  init_workspace
  init_config
  build_load_spec
  write_output
  validate_output
  emit_output
}

main "$@"
