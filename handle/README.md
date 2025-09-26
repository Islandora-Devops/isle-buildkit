# Handle

Docker image for [Handle] version 9.3.1.

Built from [Islandora-DevOps/isle-buildkit handle](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/handle)

Please refer to the [Handle Documentation] for more in-depth information.

As a quick example this will bring up an instance of [Handle], and allow you
to view on <http://localhost:8000/>.

```bash
docker run --rm -ti -p 8000:8000 islandora/handle
```

## Dependencies

Requires `islandora/java` docker image to build. Please refer to the
[Java Image README](https://github.com/Islandora-Devops/isle-buildkit/blob/main/java/README.md) for additional information.

## Ports

| Port           | Description                                                                            |
| :------------- | :------------------------------------------------------------------------------------- |
| 8000 (tcp)     | Port 8000 offers an HTTP and HTTPS interface.                                          |
| 2641 (udp/tcp) | Port 2641 (UDP and TCP) is the IANA-assigned port number for the Handle wire protocol. |

## Settings

### Confd Settings

| Environment Variable         | Default                                              | Description                                                                                         |
| :--------------------------- | :--------------------------------------------------- | :-------------------------------------------------------------------------------------------------- |
| HANDLE_ADMIN_FULL_ACCESS     | yes                                                  | "yes" or "no". If set to "no" the "server_admins" will have default permissions at the prefix level |
| HANDLE_ADMIN_PRIVATE_KEY_PEM | See rootfs/etc/defaults/HANDLE_ADMIN_PRIVATE_KEY_PEM | Please read the handle documentation for how this is use                                            |
| HANDLE_ADMIN_PUBLIC_KEY_PEM  | See rootfs/etc/defaults/HANDLE_ADMIN_PUBLIC_KEY_PEM  | Please read the handle documentation for how this is use                                            |
| HANDLE_ALLOW_NA_ADMINS       | yes                                                  | "yes" or "no". Allow admins from GHR?                                                               |
| HANDLE_AUTO_HOME             | yes                                                  | "yes" or "no".  Controls whether the `auto_homed_prefixes` clause is included in the server configuration (config.dct).                                                         |
| HANDLE_CASE_SENSITIVE        | no                                                   | "yes" or "no". Whether or not handles are case sensitive                                            |
| HANDLE_DB_NAME               | handle                                               | The name of the handle database                                                                     |
| HANDLE_DB_PASSWORD           | password                                             | The database users password                                                                         |
| HANDLE_DB_READONLY           | no                                                   | A boolean setting (can be "yes" or "no") prevent / allow database modification                      |
| HANDLE_DB_USER               | handle                                               | The database user                                                                                   |
| HANDLE_MAX_AUTH_TIME         | 60000                                                | The number of seconds to wait for a client to respond to an authentication challenge                |
| HANDLE_MAX_SESSION_TIME      | 86400000                                             | Time in milliseconds that an authenticated client session can persist                               |
| HANDLE_PREFIX                | 200                                                  | Please read the handle documentation for how this is use                                            |
| HANDLE_PRIVATE_KEY_PEM       | See rootfs/etc/defaults/HANDLE_PRIVATE_KEY_PEM       | Please read the handle documentation for how this is use                                            |
| HANDLE_PUBLIC_KEY_PEM        | See rootfs/etc/defaults/HANDLE_PUBLIC_KEY_PEM        | Please read the handle documentation for how this is use                                            |
| HANDLE_SERVER_ID             | 1                                                    | Used to distinguish from other servers within the same site                                         |
| HANDLE_PERSISTENCE_TYPE      | bdbje                                                | Can be 'sql', if 'bdbje' make sure to create a volume at `/var/handle/bdbje` to persist changes     |
| HANDLE_TEMPLATE_NS_OVERRIDE  | no                                                   | Prefer server_config settings.                                                                      |

**Note:** For PEM files the private key must conform to
[PKCS#8](https://en.wikipedia.org/wiki/PKCS_8) and not
[PKCS#1](https://en.wikipedia.org/wiki/PKCS_1) as the tools which do key
conversion into the handle format do not support `PKCS#1`.

i.e PEM files which begin with `-----BEGIN RSA PRIVATE KEY-----` are not
supported only keys which start with `-----BEGIN PRIVATE KEY-----` or
`-----BEGIN ENCRYPTED PRIVATE KEY-----` are supported. Note if you use encrypted
keys you will need to handle the decryption of them as it is not handled by this
image at this time.

### Database Settings

[Handle] can optionally make use of different database backends for storage. Please see
the documentation in the [base image] for more information about the default
database connection configuration.

The following settings are only used if `HANDLE_PERSISTENCE_TYPE` is set to
`mysql` or `postgresql`.

| Environment Variable | Default  | Description                                              |
| :------------------- | :------- | :------------------------------------------------------- |
| HANDLE_DB_NAME       | handle   | The name of the database                                 |
| HANDLE_DB_USER       | handle   | The user to connect to the database                      |
| HANDLE_DB_PASSWORD   | password | The password of the user used to connect to the database |

Additionally the `DB_DRIVER` variable is derived from the
`HANDLE_PERSISTENCE_TYPE` so users do not need to specify it separately.

[base image]: ../base/README.md
[Handle Documentation]: https://www.handle.net/tech_manual/HN_Tech_Manual_9.pdf
[Handle]: https://handle.net/
