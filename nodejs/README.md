# NodeJS

Docker image for `nodejs` package.

It is not meant to be deployed as a service, but rather as base to import our
custom nodejs build into containers like `islandora/code-server`.

Consumers are expected to follow this pattern:

```dockerfile
FROM islandora/nodejs:latest as nodejs

FROM some_image:latest

RUN --mount=type=bind,from=nodejs,source=/home/builder/packages/x86_64,target=/packages \
    --mount=type=bind,from=nodejs,source=/etc/apk/keys,target=/etc/apk/keys \
    apk add /packages/nodejs-*.apk && \
    ... other build steps ... && \
    cleanup.sh
```
