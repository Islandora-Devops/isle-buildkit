# Fits

Docker image for [Fits](https://projects.iq.harvard.edu/fits/home) version 1.6.0, built from [Islandora-DevOps/isle-buildkit](https://github.com/Islandora-DevOps/isle-buildkit/).

Please refer to the [Fits Documentation] for more in-depth information.

As a quick example this will bring up an instance of [Fits](https://projects.iq.harvard.edu/fits/home), and allow you
to view on <http://localhost:80/fits/>.

```bash
docker run --rm -ti -p 80:80 islandora/fits
```

## Dependencies

Requires `islandora/tomcat` docker image to build. Please refer to the
[Tomcat Image README](../tomcat/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable         | Default | Description                                                                                                          |
| :--------------------------- | :------ | :------------------------------------------------------------------------------------------------------------------- |
| FITS_MAX_IN_MEMORY_FILE_SIZE | 4       | Maximum size of an uploaded size kept in memory in MiB. Otherwise temporarily persisted to disk.                     |
| FITS_MAX_OBJECTS_IN_POOL     | 5       | Number of objects in FITSServlet object pool.                                                                        |
| FITS_MAX_REQUEST_SIZE        | 2000    | Maximum size of HTTP Request object in MiB. Must be equal to or larger than the value for /fits/max/upload/file/size |
| FITS_MAX_UPLOAD_FILE_SIZE    | 2000    | Maximum allowable size of uploaded file in MiB.                                                                      |
| FITS_SERVICE_LOG_LEVEL       | INFO    | Log level. Possible Values: OFF, FATAL, ERROR, WARN, INFO, DEBUG, TRACE or ALL                                       |

## Logs

[Fits Documentation]: https://wiki.lyrasis.org/display/FF
[Fits]: https://github.com/fits4/fits4
