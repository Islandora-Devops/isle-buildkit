# Crayfits

Docker image for [CrayFits] (**unreleased version**).

Acts as base Docker image for CrayFits based micro-services. It is not meant to
be run on its own.

## Dependencies

Requires `islandora/nginx` docker image to build. Please refer to the
[Nginx Image README](../nginx/README.md) for additional information including
additional settings, volumes, ports, etc.

## Ports

| Port | Description |
| :--- | :---------- |
| 8000 | HTTP        |

## Settings

| Environment Variable    | Default                | Description                                                                                       |
| :---------------------- | :--------------------- | :------------------------------------------------------------------------------------------------ |
| CRAYFITS_LOG_LEVEL      | info                   | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none |
| CRAYFITS_WEBSERVICE_URI | fits:8080/fits/examine | The URL of the FITS servlet.                                                                      |

## Updating

You can change the commit used for crayfits by modifying the build argument
`COMMIT` and `SHA256` in the `Dockerfile` shown as `XXXXXXXXXXXX` in the
following snippet:

```Dockerfile
ARG COMMIT=XXXXXXXXXXXX
#...
ARG SHA256=XXXXXXXXXXXX
```

You can generate the `SHA256` with the following commands:

```bash
COMMIT=$(cat crayfits/Dockerfile | grep -o 'COMMIT=.*' | cut -f2 -d=)
FILE=$(cat crayfits/Dockerfile | grep -o 'FILE=.*' | cut -f2 -d=)
URL=$(cat crayfits/Dockerfile | grep -o 'URL=.*' | cut -f2 -d=)
FILE=$(eval "echo $FILE")
URL=$(eval "echo $URL")
wget --quiet "${URL}"
shasum -a 256 "${FILE}" | cut -f1 -d' '
rm "${FILE}"
```

When changing the `COMMIT` and `SHA256` be sure to also update the composer lock files, this
can be done with the following commands:

```bash
make bake TARGET=crayfits

docker run --rm -ti \
  -v $(pwd)/crayfits/rootfs/var/www/crayfits/composer.lock:/var/www/crayfits/composer.lock \
  --entrypoint ash islandora.dev/crayfits:latest -c \
    "cd /var/www/crayfits && composer update"
```

[CrayFits]: https://github.com/roblib/CrayFits
