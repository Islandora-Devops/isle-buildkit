# Coder

Docker image for [code-server] 4.99.4.

Built from [Islandora-DevOps/isle-buildkit code-server](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/code-server)

Please refer to the [code-server Documentation] for more in-depth information.

Allows for shared development environment hosted in the browser.

Adds some debugging utilities and changes `nginx` and `php-fpm` configuration
such that two `php` processes run, one with `xdebug` and one without. The
`xdebug` process will be used if `XDEBUG_SESSION` cookie is present in the
request otherwise it will go to the much faster `non-xdebug` process.

## Requirements

For a good experience, it is recommended at least:

- 1 GB of RAM
- 2 cores

## Dependencies

Requires `islandora/drupal` docker image to build. Please refer to the
[Drupal Image README](../drupal/README.md) for additional information including
additional settings, volumes, ports, etc.

## Ports

| Port | Description |
| :--- | :---------- |
| 80   | Nginx       |
| 8443 | Code server |
| 9003 | XDebug      |

## Volumes

| Path                  | Description       |
| :-------------------- | :---------------- |
| /opt/code-server/data | code-server cache |

It is expected that this image will be used in conjunction with the
[drupal image]. Such that the [code-server] container is responsible for serving
the `Drupal` site as well as hosting `xdebug`, and [code-server].

To achieve the the Drupal should create a volume for the Drupal root and any of
any of its public / private file volumes. These volumes can then be mounted at
the same locations within the [code-server] container with the `nocopy` flag
set. Also make sure your create the `Drupal` container before the [code-server]
container so the volumes are correctly populated with content from the `Drupal`
image.

## Settings

### Code Server

| Environment Variable       | Default  | Description                                                    |
| :------------------------- | :------- | :------------------------------------------------------------- |
| CODE_SERVER_AUTHENTICATION | password | Must be either 'none' or 'password'                            |
| CODE_SERVER_PASSWORD       | password | Only used if `CODE_SERVER_AUTHENTICATION` is set to 'password' |

Code server provides shell access to the server on which it is running, for that
reason **never** use it in a situation where it is accessible publicly from the
internet without setting a strong password. Or alternatively do not use a
password and instead use port forwarding so that it is inaccessible publicly.

### XDebug

| Environment Variable | Default                      | Description                                                                |
| :------------------- | :--------------------------- | :------------------------------------------------------------------------- |
| XDEBUG_FLAGS         | -d xdebug.mode=develop,debug | See [XDebug Documentation] for settings, and prefix each setting with `-d` |

[drupal image]: ../drupal/README.md
[code-server]: https://github.com/cdr/code-server
[code-server Documentation]: https://github.com/cdr/code-server
[XDebug Documentation]: https://xdebug.org/docs/all_settings
