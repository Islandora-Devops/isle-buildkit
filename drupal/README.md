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

### Database Settings

[Drupal] can make use of different database backends for storage. Please see the
documentation in the [base image] for more information about the default
database connection configuration.

| Environment Variable            | Confd Key                | Default | Description                                                                           |
| :------------------------------ | :----------------------- | :------ | :------------------------------------------------------------------------------------ |
| DRUPAL_DEFAULT_DB_DRIVER        | /drupal/db/driver        |         | The database driver. Defaults to `DB_DRIVER`                                          |
| DRUPAL_DEFAULT_DB_HOST          | /drupal/db/host          |         | The database host. Defaults to `DB_HOST`                                              |
| DRUPAL_DEFAULT_DB_PORT          | /drupal/db/port          |         | The database port. Defaults to `DB_PORT`                                              |
| DRUPAL_DEFAULT_DB_ROOT_PASSWORD | /drupal/db/root/password |         | The database root user password. Defaults to `DB_ROOT_PASSWORD`                       |
| DRUPAL_DEFAULT_DB_ROOT_USER     | /drupal/db/root/user     |         | The database root user (used to create the site database). Defaults to `DB_ROOT_USER` |

These variables also provide the default for their site specific variants such
as `DRUPAL_SITE_{SITE}_DB_HOST` are defined.

### JWT Settings

[Drupal] is expected to make use of JWT for authentication. Please see the
documentation in the [base image] for more information.

The public/private key pair used here should be the same key as is used in the
`crayfish` and `fcrepo` based containers.

### Default Site

| Environment Variable            | Confd Key                        | Default                 | Description                                        |
| :------------------------------ | :------------------------------- | :---------------------- | :------------------------------------------------- |
| DRUPAL_DEFAULT_ACCOUNT_EMAIL    | /drupal/default/account/email    | webmaster@localhost.com | The email to use for the admin account             |
| DRUPAL_DEFAULT_ACCOUNT_NAME     | /drupal/default/account/name     | admin                   | The Drupal administrator user                      |
| DRUPAL_DEFAULT_ACCOUNT_PASSWORD | /drupal/default/account/password | password                | The Drupal administrator user password             |
| DRUPAL_DEFAULT_DB_NAME          | /drupal/default/db/name          | drupal_default          | The name of the sites database                     |
| DRUPAL_DEFAULT_DB_PASSWORD      | /drupal/default/db/password      | password                | The database users password                        |
| DRUPAL_DEFAULT_DB_USER          | /drupal/default/db/user          | drupal_default          | The database user used by the site                 |
| DRUPAL_DEFAULT_EMAIL            | /drupal/default/email            | webmaster@localhost.com | The Drupal administrators email                    |
| DRUPAL_DEFAULT_LOCALE           | /drupal/default/locale           | en                      | The Drupal sites locale                            |
| DRUPAL_DEFAULT_NAME             | /drupal/default/name             | default                 | The Drupal sites name                              |
| DRUPAL_DEFAULT_PROFILE          | /drupal/default/profile          | standard                | The installation profile to use                    |
| DRUPAL_DEFAULT_SUBDIR           | /drupal/default/subdir           | default                 | The installation profile to use                    |
| DRUPAL_DEFAULT_CONFIGDIR        | /drupal/default/configdir        |                         | Install using existing config files from directory |
| DRUPAL_DEFAULT_INSTALL          | /drupal/default/install          | true                    | Perform install if not already installed           |

Of the above you should provide at a minium your own passwords when running in
production.

### Multi-site

Additional multi-sites can be defined by adding more environment variables,
following the above conventions, only the `DRUPAL_SITE_{SITE}_NAME` is required
to create an additional site:

| Environment Variable                | Confd Key                            | Default                 | Description                                        |
| :---------------------------------- | :----------------------------------- | :---------------------- | :------------------------------------------------- |
| DRUPAL_SITE_{SITE}_ACCOUNT_EMAIL    | /drupal/site/{SITE}/account/email    | webmaster@localhost.com | The email to use for the admin account             |
| DRUPAL_SITE_{SITE}_ACCOUNT_NAME     | /drupal/site/{SITE}/account/name     | admin                   | The Drupal administrator user                      |
| DRUPAL_SITE_{SITE}_ACCOUNT_PASSWORD | /drupal/site/{SITE}/account/password | password                | The Drupal administrator user password             |
| DRUPAL_SITE_{SITE}_DB_NAME          | /drupal/site/{SITE}/db/name          | drupal_{SITE}           | The name of the sites database                     |
| DRUPAL_SITE_{SITE}_DB_PASSWORD      | /drupal/site/{SITE}/db/password      | password                | The database users password                        |
| DRUPAL_SITE_{SITE}_DB_USER          | /drupal/site/{SITE}/db/user          | drupal_{SITE}           | The database user used by the site                 |
| DRUPAL_SITE_{SITE}_EMAIL            | /drupal/site/{SITE}/email            | webmaster@localhost.com | The Drupal administrators email                    |
| DRUPAL_SITE_{SITE}_LOCALE           | /drupal/site/{SITE}/locale           | en                      | The Drupal sites locale                            |
| DRUPAL_SITE_{SITE}_NAME             | /drupal/site/{SITE}/name             |                         | The Drupal sites name                              |
| DRUPAL_SITE_{SITE}_PROFILE          | /drupal/site/{SITE}/profile          | standard                | The installation profile to use                    |
| DRUPAL_SITE_{SITE}_SUBDIR           | /drupal/site/{SITE}/subdir           | {SITE}                  | The subdirectory to install the sub-site into      |
| DRUPAL_SITE_{SITE}_CONFIGDIR        | /drupal/site/{SITE}/configdir        |                         | Install using existing config files from directory |
| DRUPAL_SITE_{SITE}_INSTALL          | /drupal/site/{SITE}/install          | true                    | Perform install if not already installed           |

[base image]: ../base/README.md
[Drupal]: https://www.drupal.org/
