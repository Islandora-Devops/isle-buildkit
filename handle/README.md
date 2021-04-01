# Handle

Docker image for [Handle] version 9.3.0.

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

| Environment Variable         | Confd Key                     | Default                                              | Description                                                                                         |
| :--------------------------- | :---------------------------- | :--------------------------------------------------- | :-------------------------------------------------------------------------------------------------- |
| HANDLE_ADMIN_FULL_ACCESS     | /handle/admin/full/access     | yes                                                  | "yes" or "no". If set to "no" the "server_admins" will have default permissions at the prefix level |
| HANDLE_ADMIN_PRIVATE_KEY_PEM | /handle/admin/private/key/pem | See rootfs/etc/defaults/HANDLE_ADMIN_PRIVATE_KEY_PEM | Please read the handle documentation for how this is use                                            |
| HANDLE_ADMIN_PUBLIC_KEY_PEM  | /handle/admin/public/key/pem  | See rootfs/etc/defaults/HANDLE_ADMIN_PUBLIC_KEY_PEM  | Please read the handle documentation for how this is use                                            |
| HANDLE_ALLOW_NA_ADMINS       | /handle/allow/na/admins       | yes                                                  | "yes" or "no". Allow admins from GHR?                                                               |
| HANDLE_CASE_SENSITIVE        | /handle/case/sensitive        | no                                                   | "yes" or "no". Whether or not handles are case sensitive                                            |
| HANDLE_DB_NAME               | /handle/db/name               | handle                                               | The name of the handle database                                                                     |
| HANDLE_DB_PASSWORD           | /handle/db/password           | password                                             | The database users password                                                                         |
| HANDLE_DB_READONLY           | /handle/db/readonly           | no                                                   | A boolean setting (can be "yes" or "no") prevent / allow database modification                      |
| HANDLE_DB_USER               | /handle/db/user               | handle                                               | The database user                                                                                   |
| HANDLE_MAX_AUTH_TIME         | /handle/max/auth/time         | 60000                                                | The number of seconds to wait for a client to respond to an authentication challenge                |
| HANDLE_MAX_SESSION_TIME      | /handle/max/session/time      | 86400000                                             | Time in milliseconds that an authenticated client session can persist                               |
| HANDLE_PREFIX                | /handle/prefix                | 200                                                  | Please read the handle documentation for how this is use                                            |
| HANDLE_PRIVATE_KEY_PEM       | /handle/private/key/pem       | See rootfs/etc/defaults/HANDLE_PRIVATE_KEY_PEM       | Please read the handle documentation for how this is use                                            |
| HANDLE_PUBLIC_KEY_PEM        | /handle/public/key/pem        | See rootfs/etc/defaults/HANDLE_PUBLIC_KEY_PEM        | Please read the handle documentation for how this is use                                            |
| HANDLE_SERVER_ID             | /handle/server/id             | 1                                                    | Used to distinguish from other servers within the same site                                         |
| HANDLE_PERSISTENCE_TYPE      | /handle/persistence/type      | bdbje                                                | Can be 'sql', if 'bdbje' make sure to create a volume at `/var/handle/bdbje` to persist changes     |
| HANDLE_TEMPLATE_NS_OVERRIDE  | /handle/template/ns/override  | no                                                   | Prefer server_config settings.                                                                      |

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

| Environment Variable | Confd Key           | Default  | Description                                              |
| :------------------- | :------------------ | :------- | :------------------------------------------------------- |
| HANDLE_DB_NAME       | /handle/db/name     | handle   | The name of the database                                 |
| HANDLE_DB_USER       | /handle/db/user     | handle   | The user to connect to the database                      |
| HANDLE_DB_PASSWORD   | /handle/db/password | password | The password of the user used to connect to the database |

Additionally the `DB_DRIVER` variable is derived from the
`HANDLE_PERSISTENCE_TYPE` so users do not need to specify it separately.

[base image]: ../base/README.md
[Handle Documentation]: https://www.handle.net/tech_manual/HN_Tech_Manual_9.pdf
[Handle]: https://handle.net/
