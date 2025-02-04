# Homarus

Docker image for [Homarus], built from [Islandora-DevOps/isle-buildkit](https://github.com/Islandora-DevOps/isle-buildkit/).

## Dependencies

Requires `islandora/crayfish` docker image to build. Please refer to the
[Crayfish Image README](../crayfish/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable            | Default                        | Description                                                                                                                     |
| :------------------------------ | :----------------------------- | :------------------------------------------------------------------------------------------------------------------------------ |
| HOMARUS_APIX_MIDDLEWARE_ENABLED | false                          | This disables the `ApixMiddleware` as we pass the full URL to `ffmpeg` instead of downloading the file and passing it directly. |
| HOMARUS_FCREPO_URL              | http://fcrepo:8080/fcrepo/rest | Fcrepo Rest API URL                                                                                                             |
| HOMARUS_LOG_LEVEL               | info                           | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none                               |

[Homarus]: https://github.com/Islandora/Crayfish/tree/4.x/Homarus
