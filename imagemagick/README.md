# Imagemagick

Docker image for `imagemagick` package.

It is not meant to be deployed as a service, but rather as base to import our
custom imagemagick build into containers like `islandora/houdini`.

Consumers are expected to follow this pattern:

```dockerfile
FROM islandora/imagemagick:latest as imagemagick

FROM some_image:latest

RUN --mount=type=bind,from=imagemagick,source=/home/builder/packages/x86_64,target=/packages \
    --mount=type=bind,from=imagemagick,source=/etc/apk/keys,target=/etc/apk/keys \
    apk add /packages/imagemagick-*.apk && \
    ... other build steps ... && \
    cleanup.sh
```

## Dependencies

Requires `islandora/abuild` docker image to build. Please refer to the
[ABuild Image README](../abuild/README.md) for additional information.
