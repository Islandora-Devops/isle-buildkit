# Milliner

Docker image for [Milliner].

Built from [Islandora-DevOps/isle-buildkit milliner](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/images/milliner)

The image downloads the tagged [Crayfish] source release configured by
`CRAYFISH_VERSION`, which contains Milliner, and installs its locked Composer
dependencies.

## Dependencies

Requires the `islandora/nginx` Docker image to build. Please refer to the
[Nginx Image README](../nginx/README.md) for additional settings, volumes,
ports, and runtime behavior.

## Updating

Update `CRAYFISH_VERSION` and `CRAYFISH_SHA256` together in the `Dockerfile`.
Renovate performs both updates for tagged [Crayfish] releases. Dependency and
lock-file changes must be made upstream before publishing the release.

## Settings

| Environment Variable | Default                        | Description                                                                                       |
| :------------------- | :----------------------------- | :------------------------------------------------------------------------------------------------ |
| MILLINER_FCREPO_URL  | http://fcrepo:8080/fcrepo/rest | Fcrepo Rest API URL                                                                               |
| MILLINER_FEDORA6    | true                           | Set to "true" if using Fedora 6 and set to "false" if using Fedora 4 or 5                         |
| MILLINER_LOG_LEVEL   | info                           | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none |

[Crayfish]: https://github.com/Islandora/Crayfish/releases
[Milliner]: https://github.com/Islandora/Crayfish/tree/5.x/Milliner
