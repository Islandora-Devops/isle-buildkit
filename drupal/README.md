# Drupal

Docker image for [Drupal].

Acts as base Docker image for Drupal based projects, it doesn't install Drupal
as consumers of this image are expected to provide their own composer file.
Instead it provides startup scripts that allow Drupal to be installed when the
image is first run.

## Dependencies

Requires `islandora/nginx` docker image to build. Please refer to the
[Nginx Image README](../nginx/README.md) for additional information including
additional settings, volumes, ports, etc.

## Ports

| Port | Description |
| :--- | :---------- |
| 80   | HTTP        |

## Settings

| Environment Variable            | Etcd Key                         | Default                 | Description                                               |
| :------------------------------ | :------------------------------- | :---------------------- | :-------------------------------------------------------- |
| DRUPAL_DB_DRIVER                | /drupal/db/driver                | mysql                   | The database driver                                       |
| DRUPAL_DB_HOST                  | /drupal/db/host                  | database                | The database host                                         |
| DRUPAL_DB_PORT                  | /drupal/db/port                  | 3306                    | The database port                                         |
| DRUPAL_DB_ROOT_PASSWORD         | /drupal/db/root/password         | password                | The database root user (used to create the site database) |
| DRUPAL_DB_ROOT_USER             | /drupal/db/root/user             | root                    | The database root user password                           |
| DRUPAL_DEFAULT_ACCOUNT_EMAIL    | /drupal/default/account/email    | webmaster@localhost.com | The email to use for the admin account                    |
| DRUPAL_DEFAULT_ACCOUNT_NAME     | /drupal/default/account/name     | admin                   | The Drupal administrator user                             |
| DRUPAL_DEFAULT_ACCOUNT_PASSWORD | /drupal/default/account/password | password                | The Drupal administrator user password                    |
| DRUPAL_DEFAULT_DB_NAME          | /drupal/default/db/name          | drupal_default          | The name of the sites database                            |
| DRUPAL_DEFAULT_DB_PASSWORD      | /drupal/default/db/password      | password                | The database users password                               |
| DRUPAL_DEFAULT_DB_USER          | /drupal/default/db/user          | drupal_default          | The database user used by the site.                       |
| DRUPAL_DEFAULT_EMAIL            | /drupal/default/email            | webmaster@localhost.com | The Drupal administrators email                           |
| DRUPAL_DEFAULT_LOCALE           | /drupal/default/locale           | en                      | The Drupal sites locale                                   |
| DRUPAL_DEFAULT_NAME             | /drupal/default/name             | default                 | The Drupal sites name                                     |
| DRUPAL_DEFAULT_PROFILE          | /drupal/default/profile          | standard                | The installation profile to use                           |

Additional multi-sites can be defined by adding more environment variables,
following the above conventions, only the `DRUPAL_SITE_{SITE}_NAME` is required
to create an additional site:

| Environment Variable                | Etcd Key                             | Default                 | Description                                   |
| :---------------------------------- | :----------------------------------- | :---------------------- | :-------------------------------------------- |
| DRUPAL_SITE_{SITE}_ACCOUNT_EMAIL    | /drupal/site/{SITE}/account/email    | webmaster@localhost.com | The email to use for the admin account        |
| DRUPAL_SITE_{SITE}_ACCOUNT_NAME     | /drupal/site/{SITE}/account/name     | admin                   | The Drupal administrator user                 |
| DRUPAL_SITE_{SITE}_ACCOUNT_PASSWORD | /drupal/site/{SITE}/account/password | password                | The Drupal administrator user password        |
| DRUPAL_SITE_{SITE}_DB_NAME          | /drupal/site/{SITE}/db/name          | drupal_{SITE}           | The name of the sites database                |
| DRUPAL_SITE_{SITE}_DB_PASSWORD      | /drupal/site/{SITE}/db/password      | password                | The database users password                   |
| DRUPAL_SITE_{SITE}_DB_USER          | /drupal/site/{SITE}/db/user          | drupal_{SITE}           | The database user used by the site.           |
| DRUPAL_SITE_{SITE}_EMAIL            | /drupal/site/{SITE}/email            | webmaster@localhost.com | The Drupal administrators email               |
| DRUPAL_SITE_{SITE}_LOCALE           | /drupal/site/{SITE}/locale           | en                      | The Drupal sites locale                       |
| DRUPAL_SITE_{SITE}_NAME             | /drupal/site/{SITE}/name             |                         | The Drupal sites name                         |
| DRUPAL_SITE_{SITE}_PROFILE          | /drupal/site/{SITE}/profile          | standard                | The installation profile to use               |
| DRUPAL_SITE_{SITE}_SUBDIR           | /drupal/site/{SITE}/subdir           | {SITE}                  | The subdirectory to install the sub-site into |

[Drupal]: https://www.drupal.org/
