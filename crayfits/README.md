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

| Environment Variable    | Confd Key                | Default                | Description                                                                                       |
| :---------------------- | :----------------------- | :--------------------- | :------------------------------------------------------------------------------------------------ |
| CRAYFITS_LOG_LEVEL      | /crayfits/log/level      | info                   | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none |
| CRAYFITS_WEBSERVICE_URI | /crayfits/webservice/uri | fits:8080/fits/examine | The URL of the FITS servlet.                                                                      |

[CrayFits]: https://github.com/roblib/CrayFits
