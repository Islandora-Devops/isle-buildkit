# Matomo

Docker image for [Matomo] version 3.13.5.

Please refer to the [Matomo Documentation] for more in-depth information.

## Dependencies

Requires `islandora/nginx` docker image to build. Please refer to the
[Nginx Image README](../nginx/README.md) for additional information including
additional settings, volumes, ports, etc.

Additionally it requires a database backend to run, and  website to aggregate
metrics for.

## Ports

| Port | Description |
| :--- | :---------- |
| 80   | HTTP        |

## Settings

| Environment Variable          | Confd Key                      | Default                                                      | Description                                                   |
| :---------------------------- | :----------------------------- | :----------------------------------------------------------- | :------------------------------------------------------------ |
| MATOMO_ASSUME_SECURE_PROTOCOL | /matomo/assume/secure/protocol | 1                                                            | <https://matomo.org/faq/how-to-install/faq_98/>               |
| MATOMO_DB_DRIVER              | /matomo/db/driver              | pdo_mysql                                                    | The database driver to use                                    |
| MATOMO_DB_HOST                | /matomo/db/host                | database                                                     | The database host                                             |
| MATOMO_DB_NAME                | /matomo/db/name                | matomo                                                       | The database name                                             |
| MATOMO_DB_PASSWORD            | /matomo/db/password            | password                                                     | The database user password                                    |
| MATOMO_DB_PORT                | /matomo/db/port                | 3306                                                         | The database port                                             |
| MATOMO_DB_ROOT_PASSWORD       | /matomo/db/root/password       | password                                                     | The root user password (used to create the database / user)   |
| MATOMO_DB_ROOT_USER           | /matomo/db/root/user           | root                                                         | The root user (used to create the database / user)            |
| MATOMO_DB_USER                | /matomo/db/user                | matomo                                                       | The user to create / use when interacting with the database   |
| MATOMO_DEFAULT_HOST           | /matomo/default/host           | islandora.traefik.me                                         | The URL of the default site for which to gather metrics for   |
| MATOMO_DEFAULT_NAME           | /matomo/default/name           | Islandora                                                    | The name of the default site                                  |
| MATOMO_DEFAULT_TIMEZONE       | /matomo/default/timezone       | America/Halifax                                              | The timezone where the default site is hosted                 |
| MATOMO_FORCE_SSL              | /matomo/force/ssl              | 1                                                            | <https://matomo.org/faq/how-to/faq_91/>                       |
| MATOMO_PROXY_CLIENT_HEADERS   | /matomo/proxy/client/headers   | HTTP_X_FORWARDED_FOR                                         | <https://matomo.org/faq/how-to-install/faq_98/>               |
| MATOMO_PROXY_HOST_HEADERS     | /matomo/proxy/host/headers     | HTTP_X_FORWARDED_HOST                                        | <https://matomo.org/faq/how-to-install/faq_98/>               |
| MATOMO_PROXY_URI_HEADER       | /matomo/proxy/uri/header       | 1                                                            | <https://matomo.org/faq/how-to-install/faq_98/>               |
| MATOMO_SALT                   | /matomo/salt                   | 5a472390550bd59e4428a41aa472137b                             | Used to generate hashes.                                      |
| MATOMO_USER_EMAIL             | /matomo/user/email             | admin@example.org                                            | The site administrator email                                  |
| MATOMO_USER_NAME              | /matomo/user/name              | admin                                                        | The site administrator user                                   |
| MATOMO_USER_PASS              | /matomo/user/pass              | $2y$10$S38e7HPM9LI3aOIvcnRsfuMCm4ipNP572QsvbCK60upoHVJ61hMrS | The site administrator's password (See how to generate below) |

To regenerate a the `MATOMO_USER_PASS` you must use the following snippet of
[PHP](https://matomo.org/faq/how-to/faq_191/).

```bash
php -r 'echo password_hash(md5("password"), PASSWORD_DEFAULT) . "\n";'
```

On production sites generate your own `MATOMO_SALT` with the following snippet
of **PHP** it is important you keep it secret along with your passwords.

```bash
php -r 'echo md5(uniqid(rand(), true));'
```

Additional multi-sites can be defined by adding more environment variables,
following the above conventions, only the `MATOMO_SITE_{SITE}_HOST` is required
to create an additional site:

| Environment Variable        | Etcd Key                     | Default         | Description                                         |
| :-------------------------- | :--------------------------- | :-------------- | :-------------------------------------------------- |
| MATOMO_SITE_{SITE}_HOST     | /matomo/site/{SITE}/host     |                 | The URL of the site for which to gather metrics for |
| MATOMO_SITE_{SITE}_NAME     | /matomo/site/{SITE}/name     | {SITE}          | The name of the site                                |
| MATOMO_SITE_{SITE}_TIMEZONE | /matomo/site/{SITE}/timezone | America/Halifax | The timezone the site is hosted in                  |

[Matomo]: https://matomo.org/
[Matomo Documentation]: https://matomo.org/docs/
