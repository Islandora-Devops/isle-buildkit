# ActiveMQ

Docker image for [ActiveMQ] version 5.17.3.

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

Requires `islandora/java` docker image to build. Please refer to the
[Java Image README](../java/README.md) for additional information including
additional settings, volumes, ports, etc.

## Ports

| Port  | Description  |
| :---- | :----------- |
| 1883  | [MQTT]       |
| 5672  | [AMPQ]       |
| 8161  | [WebConsole] |
| 61613 | [STOMP]      |
| 61614 | [WS]         |
| 61616 | [OpenWire]   |

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
| ACTIVEMQ_WEB_ADMIN_NAME     | admin    | See [WebConsole]: jetty-realm.properties                                       |
| ACTIVEMQ_WEB_ADMIN_PASSWORD | password | See [WebConsole]: jetty-realm.properties                                       |
| ACTIVEMQ_WEB_ADMIN_ROLES    | admin    | See [WebConsole]: jetty-realm.properties                                       |

Additional users/groups/etc can be defined by adding more environment variables,
following the above conventions:

| Environment Variable              | Description                              |
| :-------------------------------- | :--------------------------------------- |
| ACTIVEMQ_USER_{USER}_NAME         | See [Security]: users.properties         |
| ACTIVEMQ_USER_{USER}_PASSWORD     | See [Security]: users.properties         |
| ACTIVEMQ_GROUP_{GROUP}_NAME       | See [Security]: groups.properties        |
| ACTIVEMQ_GROUP_{GROUP}_MEMBERS    | See [Security]: groups.properties        |
| ACTIVEMQ_WEB_USER_{USER}_NAME     | See [WebConsole]: jetty-realm.properties |
| ACTIVEMQ_WEB_USER_{USER}_PASSWORD | See [WebConsole]: jetty-realm.properties |
| ACTIVEMQ_WEB_USER_{USER}_ROLES    | See [WebConsole]: jetty-realm.properties |

> N.B. These do not have defaults.

For example to add a new user `someone` to the [WebConsole] you would need to
define the following:

| Environment Variable               | Value    |
| :--------------------------------- | :------- |
| ACTIVEMQ_WEB_USER_SOMEONE_NAME     | someone  |
| ACTIVEMQ_WEB_USER_SOMEONE_PASSWORD | password |
| ACTIVEMQ_WEB_USER_SOMEONE_ROLES    | admin    |

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
