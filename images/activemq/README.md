# ActiveMQ

Docker image for [ActiveMQ] version 6.3.1.

Built from [Islandora-DevOps/isle-buildkit activemq](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/images/activemq)

Please refer to the [ActiveMQ Documentation] for more in-depth information.

As a quick example this will bring up an instance of ActiveMQ, and allow you to
log into the [WebConsole] on `http://localhost:8161` as the user `admin` with
the password `password`.

```bash
docker run --rm -ti -p 8161:8161 islandora/activemq
```

> N.B. if no credentials are given you will not be able to log in via the
[WebConsole].

## Dependencies

Requires `islandora/java` Docker image to build. Please refer to the
[Java Image README](../java/README.md) for additional information including
additional settings, volumes, ports, etc.

## Ports

| Port  | Description  | Enabled by default |
| :---- | :----------- | :----------------- |
| 1883  | [MQTT]       | No                 |
| 5672  | [AMPQ]       | No                 |
| 8161  | [WebConsole] | Yes                |
| 61613 | [STOMP]      | Yes                |
| 61614 | [WS]         | No                 |
| 61616 | [OpenWire]   | Yes                |

## Volumes

| Path               | Description         |
| :----------------- | :------------------ |
| /opt/activemq/data | [AMQ Message Store] |

## Settings

| Environment Variable        | Default  | Description                                                                    |
| :-------------------------- | :------- | :----------------------------------------------------------------------------- |
| ACTIVEMQ_AUDIT_LOG_LEVEL    | INFO     | Log level. Possible Values: OFF, FATAL, ERROR, WARN, INFO, DEBUG, TRACE or ALL |
| ACTIVEMQ_LOG_LEVEL          | INFO     | Log level. Possible Values: OFF, FATAL, ERROR, WARN, INFO, DEBUG, TRACE or ALL |
| ACTIVEMQ_PASSWORD           | password | See [Security]: credentials.properties                                         |
| ACTIVEMQ_USER               | admin    | See [Security]: credentials.properties                                         |
| ACTIVEMQ_WEB_ADMIN_NAME     | admin    | See [Security]: users.properties. Also used to log into the [WebConsole]/health API |
| ACTIVEMQ_WEB_ADMIN_PASSWORD | password | See [Security]: users.properties. Also used to log into the [WebConsole]/health API |
| ACTIVEMQ_WEB_ADMIN_ROLES    | admins   | See [Security]: groups.properties. Must be `admins` to access the [WebConsole]/Jolokia API (enforced by `conf/jetty/jetty-security.xml`) |

Additional users/groups/etc can be defined by adding more environment variables,
following the above conventions:

| Environment Variable           | Description                       |
| :------------------------------ | :--------------------------------- |
| ACTIVEMQ_USER_{USER}_NAME       | See [Security]: users.properties  |
| ACTIVEMQ_USER_{USER}_PASSWORD   | See [Security]: users.properties  |
| ACTIVEMQ_GROUP_{GROUP}_NAME     | See [Security]: groups.properties |
| ACTIVEMQ_GROUP_{GROUP}_MEMBERS  | See [Security]: groups.properties |

> N.B. These do not have defaults.

Since ActiveMQ 6.3, the broker and the [WebConsole]/Jolokia API share a single
JAAS realm (`users.properties`/`groups.properties`), so the same mechanism
above is used to grant additional users access to the [WebConsole]. For
example to add a new user `someone` with admin access to the [WebConsole] you
would need to define the following:

| Environment Variable          | Value    |
| :----------------------------- | :------- |
| ACTIVEMQ_USER_SOMEONE_NAME     | someone  |
| ACTIVEMQ_USER_SOMEONE_PASSWORD | password |
| ACTIVEMQ_GROUP_ADMINS_NAME     | admins   |
| ACTIVEMQ_GROUP_ADMINS_MEMBERS  | someone  |

> N.B. Broker-level authentication (the `jaasAuthenticationPlugin` in
> `conf/activemq.xml`) is disabled by default, so [STOMP]/[OpenWire]/etc
> connections remain unauthenticated out of the box, as before. Only the
> [WebConsole] and Jolokia API enforce login.

## Logs

- [ActiveMQ Log]
- [Audit Log]

[ActiveMQ Documentation]: https://activemq.apache.org/components/classic/documentation
[ActiveMQ Log]: https://activemq.apache.org/how-do-i-change-the-logging
[ActiveMQ]: http://activemq.apache.org/
[AMPQ]: https://activemq.apache.org/amqp
[AMQ Message Store]: https://activemq.apache.org/amq-message-store
[Audit Log]: https://activemq.apache.org/audit-logging
[MQTT]: https://activemq.apache.org/mqtt
[OpenWire]: https://activemq.apache.org/openwire
[Security]: https://activemq.apache.org/security
[STOMP]: https://activemq.apache.org/stomp
[WebConsole]: https://activemq.apache.org/web-console
[WS]: https://activemq.apache.org/ws-notification
