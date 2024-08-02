# Tomcat

Docker image for [Tomcat] version 9.0.91.

Please refer to the [Tomcat Documentation] for more in-depth information.

As a quick example this will bring up an instance of [Tomcat], and allow you
to view the manager webapp on <http://localhost:80/manager/html/>.

```bash
docker run --rm -ti \
    -p 8080:8080 \
    islandora/tomcat
```

## Dependencies

Requires `islandora/java` docker image to build. Please refer to the
[Java Image README](../java/README.md) for additional information including
additional settings, volumes, ports, etc.

## Ports

| Port | Description |
| :--- | :---------- |
| 8005 | Shut-down   |
| 8009 | [AJP]       |
| 8080 | HTTP        |
| 8443 | HTTPS       |

## Settings

| Environment Variable                | Default     | Description                                                                           |
| :---------------------------------- | :---------- | :------------------------------------------------------------------------------------ |
| TOMCAT_ADMIN_NAME                   | admin       | The user name of the manager webapp admin user                                        |
| TOMCAT_ADMIN_PASSWORD               | password    | The password for the manager webapp admin user                                        |
| TOMCAT_ADMIN_ROLES                  | manager-gui | Comma separated list of roles the user has                                            |
| TOMCAT_CATALINA_OPTS                |             |                                                                                       |
| TOMCAT_JAVA_OPTS                    |             |                                                                                       |
| TOMCAT_LOG_LEVEL                    | INFO        | Log level. Possible Values: SEVERE, WARNING, INFO, CONFIG, FINE, FINER, FINEST or ALL |
| TOMCAT_MANAGER_REMOTE_ADDRESS_VALVE | ^.*$        | Allows / blocks access to manager app to addresses which match this regex             |

Additional users/groups/etc can be defined by adding more environment variables,
following the above conventions:

| Environment Variable        | Description                                |
| :-------------------------- | :----------------------------------------- |
| TOMCAT_USER_{USER}_NAME     | The user name                              |
| TOMCAT_USER_{USER}_PASSWORD | The password for the user                  |
| TOMCAT_USER_{USER}_ROLES    | Comma separated list of roles the user has |

> N.B. These do not have defaults.

For example to add a new user `someone` you would need to define the following:

| Environment Variable         | Value    |
| :--------------------------- | :------- |
| TOMCAT_USER_SOMEONE_NAME     | someone  |
| TOMCAT_USER_SOMEONE_PASSWORD | password |
| TOMCAT_USER_SOMEONE_ROLES    | admin    |

> N.B. For all of the settings above, images that descend from this image can
> apply a prefix to every setting. So for example `TOMCAT_CATALINA_OPTS` would
> become `FCREPO_TOMCAT_CATALINA_OPTS`. This is to allow for different settings
> on a per-service basis when sharing the same confd backend.

[AJP]: https://tomcat.apache.org/tomcat-9.0-doc/config/ajp.html
[Tomcat Documentation]: https://tomcat.apache.org/tomcat-9.0-doc/
[Tomcat Logging]: https://tomcat.apache.org/tomcat-9.0-doc/logging.html
[Tomcat]: https://tomcat.apache.org/
