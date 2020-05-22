# Fits

Docker image for [Fits] version 5.1.0.

Please refer to the [Fits Documentation] for more in-depth information.

As a quick example this will bring up an instance of [Fits], and allow you
to view on <http://localhost:80/fits/>.

```bash
docker run --rm -ti -p 80:80 islandora/fits
```

## Dependencies

Requires `islandora/tomcat` docker image to build. Please refer to the
[Tomcat Image README](../tomcat/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable         | Etcd Key                      | Default | Description                                                                                                          |
| :--------------------------- | :---------------------------- | :------ | :------------------------------------------------------------------------------------------------------------------- |
| FITS_MAX_IN_MEMORY_FILE_SIZE | /fits/max/in/memory/file/size | 4       | Maximum size of an uploaded size kept in memory in MiB. Otherwise temporarily persisted to disk.                     |
| FITS_MAX_OBJECTS_IN_POOL     | /fits/max/objects/in/pool     | 5       | Number of objects in FITSServlet object pool.                                                                        |
| FITS_MAX_REQUEST_SIZE        | /fits/max/request/size        | 2000    | Maximum size of HTTP Request object in MiB. Must be equal to or larger than the value for /fits/max/upload/file/size |
| FITS_MAX_UPLOAD_FILE_SIZE    | /fits/max/upload/file/size    | 2000    | Maximum allowable size of uploaded file in MiB.                                                                      |

## Logs

| Path                              | Description |
| :-------------------------------- | :---------- |
| /opt/tomcat/logs/fits-service.log |             |

[Fits Documentation]: https://wiki.lyrasis.org/display/FF
[Fits]: https://github.com/fits4/fits4
