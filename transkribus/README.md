# Transkribus

Docker image for version 1.1 of the [transkribus-process microservice](https://github.com/ulsdevteam/transkribus-process)

## Dependencies

Since the microservice is a C#/.NET app, this does not use the base isle-buildkit image, instead using images provided by Microsoft that include the .NET build environment and runtime.

## Ports

Uses port 5000 by default, this can be changed using the `ASPNETCORE_URLS` environment variable.

## Settings

JWT authentication is enabled by default, and can be configured by setting `USE_JWT_AUTHENTICATION` to true or false.
