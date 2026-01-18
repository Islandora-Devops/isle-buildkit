# Transkribus

Docker image for version 1.1.0 of the [transkribus-process microservice]

Built from [Islandora-DevOps/isle-buildkit transkribus](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/images/transkribus)

Please refer to the [Transkribus Documentation] for more in-depth information.

## Dependencies

Requires `islandora/base` Docker image to build. Please refer to the
[Base Image README](../base/README.md) for additional information.

## Ports

| Port | Description                                                           |
| :--- | :-------------------------------------------------------------------- |
| 5000 | This can be changed using the `ASPNETCORE_URLS` environment variable. |

## Volumes

| Path  | Description           |
| :---- | :-------------------- |
| /data | For SQLite Database files and ASP.NET Core data. |

## Settings

JWT authentication is enabled by default, and can be configured by setting `USE_JWT_AUTHENTICATION` to true or false.

| Environment Variable               | Default                                 | Description                                                                                        |
| :--------------------------------- | :-------------------------------------- | :------------------------------------------------------------------------------------------------- |
| TRANSKRIBUS_ALTO_TO_HOCR_SEF_PATH  | alto_to_hocr.sef.json                   | Path to an `xslt` that has been compiled into an sef.json by the `xslt3` utility                   |
| TRANSKRIBUS_ASPNETCORE_URLS        | http://transkribus:5000/                | See [ASPNET Server URLs] for more information                                                      |
| TRANSKRIBUS_CONNECTION_STRING      | "Filename=/data/transkribus-process.db" | Connection string for a SQLite or MySQL database                                                   |
| TRANSKRIBUS_SERVICE_PASSWORD       |                                         | Password, used to connect to [Transkribus]                                                         |
| TRANSKRIBUS_SERVICE_USERNAME       |                                         | Username, used to connect to [Transkribus]                                                         |
| TRANSKRIBUS_USE_JWT_AUTHENTICATION | true                                    | Connect using `JWT`, see `JWT_PUBLIC_KEY` in the `base` images documentation, for more information |

[transkribus-process microservice]: https://github.com/ulsdevteam/transkribus-process
[Transkribus Documentation]: https://help.transkribus.org/
[ASPNET Server URLs]: https://learn.microsoft.com/en-us/aspnet/core/fundamentals/host/web-host?view=aspnetcore-8.0#server-urls
[Transkribus]: https://www.transkribus.org/
