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
| DRUPAL_DEFAULT_DB_USER          | /drupal/default/db/user          | drupal_default          | The database user used by the site                        |
| DRUPAL_DEFAULT_EMAIL            | /drupal/default/email            | webmaster@localhost.com | The Drupal administrators email                           |
| DRUPAL_DEFAULT_LOCALE           | /drupal/default/locale           | en                      | The Drupal sites locale                                   |
| DRUPAL_DEFAULT_NAME             | /drupal/default/name             | default                 | The Drupal sites name                                     |
| DRUPAL_DEFAULT_PROFILE          | /drupal/default/profile          | standard                | The installation profile to use                           |
| DRUPAL_DEFAULT_SUBDIR           | /drupal/default/subdir           | default                 | The installation profile to use                           |
| DRUPAL_DEFAULT_CONFIGDIR        | /drupal/default/configdir        |                         | Install using existing config files from directory        |
| DRUPAL_DEFAULT_INSTALL          | /drupal/default/install          | true                    | Perform install if not already installed                  |
| DRUPAL_FASTCGI_BUFFERS_NUMBER   | /drupal/fastcgi/buffers/number   | 8                       | nginx fastcgi_buffers number                              |
| DRUPAL_FASTCGI_BUFFERS_SIZE     | /drupal/fastcgi/buffers/size     | 16k                     | nginx fastcgi_buffers size                                |
| DRUPAL_FASTCGI_BUFFER_SIZE      | /drupal/fastcgi/buffer/size      | 32k                     | nginx fastcgi_buffer size                                 |


Additional multi-sites can be defined by adding more environment variables,
following the above conventions, only the `DRUPAL_SITE_{SITE}_NAME` is required
to create an additional site:

| Environment Variable                | Etcd Key                             | Default                 | Description                                        |
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

## Configuring SMTP
Drupal must have the following environment variables preset at runtime in order to send email through an SMTP relay.  These variables configure PHP-related SMTP settings in `php.ini` (which is parameterized by `confd`).  The only dependency is on the OpenSSL binary, which must be present in the command path (it is, by default).

Busybox sendmail is configured by default, and existing settings have been tested with GMail SMTP.  For example, to use GMail's SMTP relays, you would use the following values:
* `DRUPAL_SMTP_ENABLE`: `true`
* `DRUPAL_SMTP_AUTH_PRINCIPAL`: `<user>@gmail.com`
* `DRUPAL_SMTP_AUTH_TOKEN`: `<gmail app token>`
* `DRUPAL_SMTP_FROM_ADDRESS`: `webmaster@library.jhu.edu`
* `DRUPAL_SMTP_RELAY_HOST`: `smtp.gmail.com`

The default values for the remaining required variables suffice.

## SMTP Environment Variables

|Environment Variable        |Default Value                         |Description|
|----------------------------|--------------------------------------|--------------------------------------|
|`DRUPAL_SMTP_ENABLE`        |`` (the zero-length string)           |Determines whether SMTP is enabled or not.  Any non-empty value (e.g. `true`) may be used.  If the value is the zero-length string, none of the SMTP-related variables have affect| 
|`DRUPAL_SMTP_VERBOSE`       |`` (the zero-length string)           |Logs entire SMTP exchanges with the relay.  Any non-empty value (e.g. `true`) may be used.  Useful for debugging but does echo sensitive information to the logs.|
|`DRUPAL_SMTP_MSA_BIN`       |`sendmail`                            |(required) Path to Sendmail. By default the BusyBox sendmail wrapper is used.|
|`DRUPAL_SMTP_AUTH_MECH`     |`LOGIN`                               |(required) The SMTP auth mechanism used.  Exactly one authentication mechanism must be defined.|
|`DRUPAL_SMTP_AUTH_PRINCIPAL`|-                                     |(required) The SMTP user principal to authenticate as.  Since there is no default provided, this _must_ be defined.|
|`DRUPAL_SMTP_AUTH_TOKEN`    |-                                     |(required) The SMTP authentication token to authenticate with.  Since there is no default provided, this _must_ be defined.
|`DRUPAL_SMTP_FROM_ADDRESS`  |-                                     |(required) A trusted from address used by `MAIL FROM`.  Since there is no default provided, this _must_ be defined.|
|`DRUPAL_SMTP_RELAY_HOST`    |`email-smtp.us-east-1.amazonaws.com`  |(required) The IP address or DNS name of the SMTP relay to use.|
|`DRUPAL_SMTP_RELAY_PORT`    |`587`                                 |(required) The Mail Submission Port used by the SMTP relay.|
|`DRUPAL_SMTP_TLS_VERSION`   |`tls1_3`                              |(required) The TLS version to use.  Valid values are determined by the OpenSSL library.  Example valid values are: `tls1`, `tls1_1`, `tls1_2`, `tls1_3`.

[Drupal]: https://www.drupal.org/
