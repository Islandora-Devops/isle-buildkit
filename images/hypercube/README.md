# Hypercube

Docker image for [Hypercube]. Tesseract as a microservice

Images are converted to 8-bit greyscale with libvips before OCR, so formats
leptonica can not read (tiled TIFF, 16-bit JP2, float TIFF, HEIF) work too.

Built from [Islandora-DevOps/isle-buildkit hypercube](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/images/hypercube)

## Dependencies

Requires `islandora/scyllaridae` Docker image to build. Please refer to the
[Scyllaridae Image README](../scyllaridae/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Default | Description                                                  |
| :------------------- | :------ | :----------------------------------------------------------- |
| HYPERCUBE_MAX_SIZE   | 8000    | Images with a longer side (in pixels) are downscaled for OCR |
