# Tomcat

Docker image for [Tomcat] version 9.0.34.

Please refer to the [Tomcat Documentation] for more in-depth information.

As a quick example this will bring up an instance of [Tomcat], and allow you
to view the manager webapp on <http://localhost:80/manager/html/>.

```bash
docker run --rm -ti \
    -p 80:80 \
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

> N.B. For all of the settings below images that descend from
> ``islandora/tomcat`` will apply prefix to every setting. So for example
> `CATALINA_OPTS` would become `FCREPO_CATALINA_OPTS` this is to allow for
> different settings on a per-service basis.

| Environment Variable                | Etcd Key                             | Default     | Description                                                                           |
| :---------------------------------- | :----------------------------------- | :---------- | :------------------------------------------------------------------------------------ |
| CATALINA_OPTS                       | /catalina/opts                       |             |                                                                                       |
| JAVA_OPTS                           | /java/opts                           |             |                                                                                       |
| TOMCAT_ADMIN_NAME                   | /tomcat/admin/name                   | admin       | The user name of the manager webapp admin user                                        |
| TOMCAT_ADMIN_PASSWORD               | /tomcat/admin/password               | password    | The password for the manager webapp admin user                                        |
| TOMCAT_ADMIN_ROLES                  | /tomcat/admin/roles                  | manager-gui | Comma separated list of roles the user has                                            |
| TOMCAT_LOG_LEVEL                    | /tomcat/log/level                    | ALL         | Log level. Possible Values: SEVERE, WARNING, INFO, CONFIG, FINE, FINER, FINEST or ALL |
| TOMCAT_MANAGER_REMOTE_ADDRESS_VALVE | /tomcat/manager/remote/address/valve | ^.*$        | Allows / blocks access to manager app to addresses which match this regex             |
| TOMCAT_NGINX_PROXY_READ_TIMEOUT     | -                                    | 60          | Defines a timeout for reading a response from the proxied server, in seconds. |

Additional users/groups/etc can be defined by adding more environment variables,
following the above conventions:

| Environment Variable        | Etcd Key                     | Description                                |
| :-------------------------- | :--------------------------- | :----------------------------------------- |
| TOMCAT_USER_{USER}_NAME     | /tomcat/user/{USER}/name     | The user name                              |
| TOMCAT_USER_{USER}_PASSWORD | /tomcat/user/{USER}/password | The password for the user                  |
| TOMCAT_USER_{USER}_ROLES    | /tomcat/user/{USER}/roles    | Comma separated list of roles the user has |

> N.B. These do not have defaults.

For example to add a new user `someone` you would need to define the following:

| Environment Variable         | Etcd Key                      | Value    |
| :--------------------------- | :---------------------------- | :------- |
| TOMCAT_USER_SOMEONE_NAME     | /tomcat/user/someone/name     | someone  |
| TOMCAT_USER_SOMEONE_PASSWORD | /tomcat/user/someone/password | password |
| TOMCAT_USER_SOMEONE_ROLES    | /tomcat/user/someone/roles    | admin    |

[AJP]: https://tomcat.apache.org/tomcat-9.0-doc/config/ajp.html
[Tomcat Documentation]: https://tomcat.apache.org/tomcat-9.0-doc/
[Tomcat Logging]: https://tomcat.apache.org/tomcat-9.0-doc/logging.html
[Tomcat]: https://tomcat.apache.org/
