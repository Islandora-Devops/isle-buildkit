# Leptonica

Docker image for `leptonica` package.

It is not meant to be deployed as a service, but rather as base to import our
custom leptonica build into containers like `islandora/hypercube`.

Consumers are expected to follow this pattern:

```dockerfile
FROM islandora/leptonica:latest as leptonica

FROM some_image:latest

RUN --mount=type=bind,from=leptonica,source=/home/builder/packages/x86_64,target=/packages \
    --mount=type=bind,from=leptonica,source=/etc/apk/keys,target=/etc/apk/keys \
    apk add /packages/leptonica-*.apk && \
    ... other build steps ... && \
    cleanup.sh
```
