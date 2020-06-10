# Matomo

Docker image for [Matomo] version 3.13.5.

Please refer to the [Matomo Documentation] for more in-depth information.

## Dependencies

Requires `islandora/nginx` docker image to build. Please refer to the
[Nginx Image README](../nginx/README.md) for additional information including
additional settings, volumes, ports, etc.

Additionally it requires a database backend to run, and website to aggregate metrics for.

## Ports

| Port | Description |
| :--- | :---------- |
| 80   | HTTP        |

## Settings

| Environment Variable    | Etcd Key                 | Default                                                      | Description                                                   |
| :---------------------- | :----------------------- | :----------------------------------------------------------- | :------------------------------------------------------------ |
| MATOMO_DB_DRIVER        | /matomo/db/driver        | pdo_mysql                                                    | The database driver to use                                    |
| MATOMO_DB_HOST          | /matomo/db/host          | database                                                     | The database host                                             |
| MATOMO_DB_NAME          | /matomo/db/name          | matomo                                                       | The database name                                             |
| MATOMO_DB_PASSWORD      | /matomo/db/password      | password                                                     | The database user password                                    |
| MATOMO_DB_PORT          | /matomo/db/port          | 3306                                                         | The database port                                             |
| MATOMO_DB_ROOT_PASSWORD | /matomo/db/root/password | password                                                     | The root user password (used to create the database / user)   |
| MATOMO_DB_ROOT_USER     | /matomo/db/root/user     | root                                                         | The root user (used to create the database / user)            |
| MATOMO_DB_USER          | /matomo/db/user          | matomo                                                       | The user to create / use when interacting with the database   |
| MATOMO_SITE_HOST        | /matomo/site/host        | islandora.localhost                                          | The URL of the site for which to gather metrics for           |
| MATOMO_SITE_NAME        | /matomo/site/name        | Islandora                                                    | The name of the site                                          |
| MATOMO_SITE_TIMEZONE    | /matomo/site/timezone    | America/Halifax                                              | The timezone the site is hosted in                            |
| MATOMO_USER_EMAIL       | /matomo/user/email       | admin@example.org                                            | The site administrator email                                  |
| MATOMO_USER_NAME        | /matomo/user/name        | admin                                                        | The site administrator user                                   |
| MATOMO_USER_PASS        | /matomo/user/pass        | $2y$10$S38e7HPM9LI3aOIvcnRsfuMCm4ipNP572QsvbCK60upoHVJ61hMrS | The site administrator's password (See how to generate below) |

To regenerate a the `MATOMO_USER_PASS` you must use the following snippet of [PHP](https://matomo.org/faq/how-to/faq_191/).

```base
php -r 'echo password_hash(md5("password"), PASSWORD_DEFAULT) . "\n";'
```

[Matomo]: https://matomo.org/
[Matomo Documentation]: https://matomo.org/docs/
