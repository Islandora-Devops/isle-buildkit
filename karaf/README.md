# Karaf

Docker image for [Karaf] version 4.0.8

Please refer to the [Karaf Documentation] for more in-depth information.

As a quick example this will bring up an instance of karaf, and allow you to
log view the [WebConsole] on <http://localhost:8181/system/console/> as the user `admin` with
the password `password`.

```bash
docker run --rm -ti \
    -p 8181:8181 \
    -e "KARAF_ADMIN_NAME=admin" \
    -e "KARAF_ADMIN_PASSWORD=password" \
    islandora/karaf
```

## Dependencies

Requires `islandora/karaf` docker image to build.

## Ports

| Port  | Description  |
| :---- | :----------- |
| 8101  | [SSH]        |
| 1099  | [RMI]        |
| 44444 | [JMX]        |
| 8181  | [WebConsole] |

## Volumes

| Path            | Description                 |
| :-------------- | :-------------------------- |
| /opt/karaf/data | [Karaf Directory Structure] |

## Settings

| Environment Variable | Etcd Key              | Default  | Description         |
| :------------------- | :-------------------- | :------- | :------------------ |
| KARAF_ADMIN_NAME     | /karaf/admin/name     | admin    | Admin user name     |
| KARAF_ADMIN_PASSWORD | /karaf/admin/password | password | Admin user password |

Additional users/groups/etc can be defined by adding more environment variables,
following the above conventions:

| Environment Variable       | Etcd Key                    | Description                      |
| :------------------------- | :-------------------------- | :------------------------------- |
| KARAF_USER_{USER}_NAME     | /karaf/user/{USER}/name     | See [Security]: users.properties |
| KARAF_USER_{USER}_PASSWORD | /karaf/user/{USER}/password | See [Security]: users.properties |
| KARAF_USER_{USER}_ROLES    | /karaf/user/{USER}/roles    | See [Security]: users.properties |
| KARAF_GROUP_{GROUP}_NAME   | /karaf/group/{GROUP}/name   | See [Security]: users.properties |
| KARAF_GROUP_{GROUP}_ROLES  | /karaf/group/{GROUP}/roles  | See [Security]: users.properties |

*N.B. These do not have defaults.*

## Logs

| Path                          | Description |
| :---------------------------- | :---------- |
| /opt/karaf/data/log/karaf.log | [Karaf Log] |

[JMX]: https://karaf.apache.org/manual/latest/#_monitoring_and_management_using_jmx
[Karaf Directory Structure]: https://karaf.apache.org/manual/latest/#_directory_structure
[Karaf Documentation]: https://islandora.github.io/documentation/
[Karaf Log]: https://karaf.apache.org/manual/latest/#_log
[Karaf]: https://github.com/Islandora/karaf
[RMI]: https://karaf.apache.org/manual/latest/monitoring
[Security]: https://karaf.apache.org/manual/latest/security
[SSH]: https://karaf.apache.org/manual/latest/remote
[WebConsole]: https://karaf.apache.org/manual/latest/webconsole
