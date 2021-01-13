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

| Environment Variable         | Etcd Key                      | Default                                               | Description                                                                                         |
| :--------------------------- | :---------------------------- | :---------------------------------------------------- | :-------------------------------------------------------------------------------------------------- |
| HANDLE_ADMIN_PRIVATE_KEY_PEM | /handle/admin/private/key/pem | See rootfs/etc/confd/templates/admin.private.key.tmpl | Please read the handle documentation for how this is use                                            |
| HANDLE_ADMIN_PUBLIC_KEY_PEM  | /handle/admin/public/key/pem  | See rootfs/etc/confd/templates/admin.public.key.tmpl  | Please read the handle documentation for how this is use                                            |
| HANDLE_ADMINFULLACCESS       | /handle/adminfullaccess       | yes                                                   | "yes" or "no". If set to "no" the "server_admins" will have default permissions at the prefix level |
| HANDLE_CASESENSITIVE         | /handle/casesensitive         | no                                                    | "yes" or "no". Whether or not handles are case sensitive                                            |
| HANDLE_DB_HOST               | /handle/db/host               | mariadb                                               | The database host                                                                                   |
| HANDLE_DB_NAME               | /handle/db/name               | handle                                                | The name of the handle database                                                                     |
| HANDLE_DB_PASSWORD           | /handle/db/password           | password                                              | The database users password                                                                         |
| HANDLE_DB_PORT               | /handle/db/port               | 3306                                                  | The database port                                                                                   |
| HANDLE_DB_READONLY           | /handle/db/readonly           | no                                                    | A boolean setting (can be "yes" or "no") prevent / allow database modification                      |
| HANDLE_DB_ROOT_PASSWORD      | /handle/db/root/password      | password                                              | The database root user password                                                                     |
| HANDLE_DB_ROOT_USER          | /handle/db/root/user          | root                                                  | The database root user (used to create the handle database)                                         |
| HANDLE_DB_USER               | /handle/db/user               | handle                                                | The database user                                                                                   |
| HANDLE_MAXAUTHTIME           | /handle/maxauthtime           | 60000                                                 | The number of seconds to wait for a client to respond to an authentication challenge                |
| HANDLE_MAXSESSIONTIME        | /handle/maxsessiontime        | 86400000                                              | Time in milliseconds that an authenticated client session can persist                               |
| HANDLE_PERSISTENCE_TYPE      | /handle/persistence/type      | mysql                                                 | The database backend to use (only used if storage type is set to sql)                               |
| HANDLE_PREFIX                | /handle/prefix                | 200                                                   | Please read the handle documentation for how this is use                                            |
| HANDLE_PRIVATE_KEY_PEM       | /handle/private/key/pem       | See rootfs/etc/confd/templates/private.key.tmpl       | Please read the handle documentation for how this is use                                            |
| HANDLE_PUBLIC_KEY_PEM        | /handle/public/key/pem        | See rootfs/etc/confd/templates/public.key.tmpl        | Please read the handle documentation for how this is use                                            |
| HANDLE_SERVERID              | /handle/serverid              | 1                                                     | Used to distinguish from other servers within the same site                                         |
| HANDLE_STORAGE_TYPE          | /handle/storage/type          | bdbje                                                 | Can be 'sql', if 'bdbje' make sure to create a volume at `/var/handle/bdbje` to persist changes     |

**Note:** For PEM files the private key must conform to
[PKCS#8](https://en.wikipedia.org/wiki/PKCS_8) and not
[PKCS#1](https://en.wikipedia.org/wiki/PKCS_1) as the tools which do key
conversion into the handle format do not support `PKCS#1`.

i.e PEM files which begin with `-----BEGIN RSA PRIVATE KEY-----` are not
supported only keys which start with `-----BEGIN PRIVATE KEY-----` or
`-----BEGIN ENCRYPTED PRIVATE KEY-----` are supported. Note if you use encrypted
keys you will need to handle the decryption of them as it is not handled by this
image at this time.

[Handle Documentation]: https://www.handle.net/tech_manual/HN_Tech_Manual_9.pdf
[Handle]: https://handle.net/
