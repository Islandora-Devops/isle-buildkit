# Milliner

Docker image for [Milliner].

## Dependencies

Requires `islandora/crayfish` docker image to build. Please refer to the
[Crayfish Image README](../crayfish/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Etcd Key             | Default                 | Description                              |
| :------------------- | :------------------- | :---------------------- | :--------------------------------------- |
| MILLINER_DRUPAL_URL  | /milliner/drupal/url | drupal:80               | Drupal URL                               |
| MILLINER_FCREPO_URL  | /milliner/fcrepo/url | fcrepo/fcrepo/rest | Fcrepo Rest API URL                      |
| MILLINER_GEMINI_URL  | /milliner/gemini/url | gemini:8000             | Gemini URL                               |
| MILLINER_LOG_LEVEL   | /milliner/log/level  | WARNING                 | The log level for Milliner micro-service |

## Logs

| Path                            | Description  |
| :------------------------------ | :----------- |
| /var/log/islandora/milliner.log | Milliner Log |

[Milliner]: https://github.com/Islandora/Crayfish/tree/master/Milliner
