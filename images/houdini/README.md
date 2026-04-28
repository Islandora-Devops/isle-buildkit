# Houdini

Docker image for [Houdini]. libvips as a microservice.

Built from [Islandora-DevOps/isle-buildkit houdini](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/images/houdini)

## Image Derivatives

The command wrapper reads the source image from stdin and writes the converted
image to stdout. It uses libvips defaults that are intended for web service
derivatives:

- TIFF output is tiled, pyramidal BigTIFF with JPEG compression.
- JPEG, PNG, and WebP output is downscaled to `HOUDINI_MAX_DIMENSION`, default
  `4096`, without upscaling.
- JP2 output is written through libvips with explicit quality and tile size
  options.

Optional tuning:

- `HOUDINI_MAX_DIMENSION`, default `4096`
- `HOUDINI_TILE_WIDTH`, default `512`
- `HOUDINI_TILE_HEIGHT`, default `512`
- `HOUDINI_JPEG_QUALITY`, default `85`
- `HOUDINI_WEBP_QUALITY`, default `85`
- `HOUDINI_JP2_QUALITY`, default `85`

## Dependencies

Requires `islandora/scyllaridae` Docker image to build. Please refer to the
[Scyllaridae Image README](../scyllaridae/README.md) for additional information including
additional settings, volumes, ports, etc.
