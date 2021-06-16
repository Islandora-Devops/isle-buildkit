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

> N.B. For all of the settings below images that descend from
> ``islandora/crayfits`` will apply prefix to every setting. So for example
> `JWT_ADMIN_TOKEN` would become `GEMINI_JWT_ADMIN_TOKEN` this is to allow for
> different settings on a per-service basis.

| Environment Variable    | Etcd Key                 | Default           | Description                                                                                       |
| :---------------------- | :----------------------- | :---------------- | :------------------------------------------------------------------------------------------------ |
| CRAYFITS_LOG_LEVEL      | /crayfits/log/level      | debug             | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none |
| CRAYFITS_WEBSERVICE_URI | /crayfits/webservice/uri | fits/fits/examine | The URL of the FITS servlet.                                                                      |

### Timeout configuration

| Environment Variable    | Etcd Key                 | Default           | Description                                                                                       |
| :---------------------- | :----------------------- | :---------------- | :------------------------------------------------------------------------------------------------ |
| PHP_MAX_EXECUTION_TIME  | -                        | 60                | The value of `PHP_MAX_EXECUTION_TIME` is used to set the Nginx `fastcgi_read_timeout` parameter   |

[CrayFits]: https://github.com/roblib/CrayFits
