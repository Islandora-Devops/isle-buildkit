# ISLE: Docker Prototype <!-- omit in toc -->

[![LICENSE](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](./LICENSE)

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Building](#building)
  - [Build All Images](#build-all-images)
  - [Build Specific Image](#build-specific-image)
  - [Building Continuously](#building-continuously)
- [Running](#running)
- [Scripts](#scripts)
- [Docker Images](#docker-images)
- [Docker Compose](#docker-compose)
  - [Watchtower](#watchtower)
  - [Traefik](#traefik)
- [ETCD](#etcd)
- [Customizing the Drupal Installation](#customizing-the-drupal-installation)
- [Design Considerations](#design-considerations)
  - [Confd](#confd)
  - [S6 Overlay](#s6-overlay)
  - [Image Hierarchy](#image-hierarchy)
  - [Folder Layout](#folder-layout)
  - [Build System](#build-system)
- [Design Constraints](#design-constraints)
- [To Do](#to-do)

## Introduction

This repository provides a number of docker images and an example
[docker-compose.yml](./docker-compose.yml) for running the demo version of
Islandora. It is not yet in a production ready state.

## Requirements

To build the Docker images using the provided Gradle build scripts requires:

- [Docker 18.09+](https://docs.docker.com/get-docker/)
- [OpenJDK or Oracle JDK 8+](https://www.java.com/en/download/)

To run the Docker images with Docker Compose requires:

- [Docker 18.06+](https://docs.docker.com/get-docker/)
- [Docker Compose 1.22+](https://docs.docker.com/compose/install/)

That being said the images themselves are compatible with older versions of
Docker, if you require running on an older version you'll need to write your own
docker-compose file.

## Building

The build scripts rely on Gradle and should function equally well across
platforms. The only difference being the script you call to interact with gradle
(the following assumes you are executing from the **root directory** of the
project):

**Linux or OSX:**

```bash
./gradlew
```

**Windows:**

```bash
gradlew.bat
```

For the remaining examples the **Linux or OSX** call method will be used, if
using Windows substitute the call to Gradle script.

Gradle is a project/task based build system to query all the available tasks use
the following command.

```bash
./gradlew tasks --all
```

Which should return something akin to:

```bash
> Task :tasks

------------------------------------------------------------
Tasks runnable from root project
------------------------------------------------------------

...

Islandora tasks
---------------
abuild:build - Creates Docker image.
activemq:build - Creates Docker image.
alpaca:build - Creates Docker image.
base:build - Creates Docker image.

...
```

In Gradle each Project maps onto a folder in the file system path where it is
delimited by ``:`` instead of ``/`` (Unix) or ``\`` (Windows).

The root project ``:`` can be omitted.

So if you want to run a particular task ``taskname`` that resided in the project
folder ``project/subproject`` you would specify it like so:

```bash
./gradlew :project:subproject:taskname
```

To get more verbose output from Gradle use the ``--info`` argument like so:

```bash
./gradlew :PROJECT:TASK --info
```

To build all the docker images you can use the following command:

### Build All Images

The following will build all the images in the correct order.

```bash
./gradlew build
```

### Build Specific Image

To build a specific image and it's dependencies, for example
``islandora/tomcat``, you can use the following:

```bash
./gradlew tomcat:build
```

### Building Continuously

It is often helpful to build continuously where-in any change you make to any of
the Dockerfiles or other project files, will automatically trigger the building
of that image and any downstream dependencies. To do this add the
``--continuous`` flag like so:

```bash
./gradlew build --continuous
```

When this is combined with the use of ``watchtower`` and
``restart: unless-stopped`` in the [docker-compose.yml](./docker-compose.yml)
file. Images will be redeployed with the latest changes while you develop
automatically. See the [Docker Compose](#Docker-Compose) section of this
document for more details.

## Running

At the moment the example [docker-compose.yml] is the only orchestration
mechanism provided to launch all the containers, and have them work as a whole.

To start the containers use the following command:

```bash
docker-compose up -d
```

With [Docker Compose] there are many features such as displaying logs among
other things for which you can find detailed descriptions in the
[Docker Composer CLI Documentation](https://docs.docker.com/compose/reference/overview/)

For more information on the structure and design of the example
[docker-compose.yml] file see the [Docker Compose](#Docker-Compose) section of
this document.

## Scripts

Some helper scripts are provided to make development and testing more pleasurable.

- [./commands/drush.sh](./commands/drush.sh) - Wrapper around [drush] in the ``drupal service`` container.
- [./commands/etcdctrl.sh](./commands/etcdctrl.sh) - Wrapper around [etcdctrl] in the ``etcd service`` container.
- [./commands/mysql.sh](./commands/mysql.sh) - Wrapper around [mysql] client in the ``database service`` container.
- [./commands/open-in-browser.sh](./commands/shell.sh) - Attempts to open the given service in the users browser.
- [./commands/shell.sh](./commands/shell.sh) - Open ``ash`` shell in the given service container.

All of the above commands include a usage statement, which can be accessed with ``-h`` flag like so:

```bash
$ ./commands/shell.sh
    usage: shell.sh SERVICE

    Opens an ash shell in the given SERVICE's container.

    OPTIONS:
       -h --help          Show this help.
       -x --debug         Debug this script.

    Examples:
       shell.sh database
```

## Docker Images

The following docker images are provided:

- [abuild](./abuild/README.md)
- [activemq](./activemq/README.md)
- [alpaca](./alpaca/README.md)
- [base](./base/README.md)
- [blazegraph](./blazegraph/README.md)
- [build](./build/README.md)
- [cantaloupe](./cantaloupe/README.md)
- [composer](./composer/README.md)
- [crayfish](./crayfish/README.md)
- [crayfits](./crayfits/README.md)
- [drupal](./drupal/README.md)
- [fcrepo](./fcrepo/README.md)
- [fits](./fits/README.md)
- [gemini](./gemini/README.md)
- [homarus](./homarus/README.md)
- [houdini](./houdini/README.md)
- [hypercube](./hypercube/README.md)
- [imagemagick](./imagemagick/README.md)
- [java](./java/README.md)
- [karaf](./karaf/README.md)
- [mariadb](./mariadb/README.md)
- [matomo](./matomo/README.md)
- [milliner](./milliner/README.md)
- [nginx](./nginx/README.md)
- [recast](./recast/README.md)
- [sandbox](./sandbox/README.md)
- [solr](./solr/README.md)
- [tomcat](./tomcat/README.md)

Many are intermediate images used to build other images in the list, for example
[java](./java/README.md). Please see the README of each image to find out what
settings, and ports, are exposed and what functionality it provides.

## Docker Compose

The example [docker-compose.yml] provided with this repository is a
template for those who wish to use [Docker Compose] for orchestration. The
images are not limited to running via [Docker Compose]. As time permits
additional tooling will be added to support [Kubernetes], and deploying to
[Amazon Elastic Container Service], and perhaps others.

The example [docker-compose.yml] runs the [sandbox](./sandbox/README.md) version
of Islandora, for the purposes of testing the images, and Islandora. When
creating a ``docker-compose.yml`` for running a production Islandora 8 site. you
will use your own image. Please see
[Customizing the Drupal Installation](#customizing-the-drupal-installation) for
instructions on how to do so.

In addition to the images provided as described in the section
[Docker Images](#docker-images). Several others are used by the
[docker-compose.yml] file.

### Watchtower

The [watchtower](https://hub.docker.com/r/v2tec/watchtower/) container monitors
the running Docker containers and watches for changes to the images that those
containers were originally started from. If watchtower detects that an image has
changed, it will automatically restart the container using the new image. This
allows for automatic deployment, and overall faster development time.

Note however Watchtower will not restart stopped container or containers that
exited due to error. To ensure a container is always running, unless explicitly
stopped, add ``restart: unless-stopped`` property to the container in the
[docker-compose.yml] file. For example:

```yaml
database:
    image: islandora/mariadb:latest
    restart: unless-stopped
```

### Traefik

The [traefik](https://containo.us/traefik/) container acts as a reverse proxy,
and exposes some containers through port ``80`` on the localhost via the
[loopback](https://www.tldp.org/LDP/nag/node66.html). This allows access to the
following urls.

- <http://activemq.localhost/admin>
- <http://blazegraph.localhost/bigdata>
- <http://drupal.localhost>
- <http://fcrepo.localhost/fcrepo/reset>
- <http://matomo.localhost>

Note if you cannot map ``traefik`` to the hosts port 80, you will need to
manually modify your ``/etc/hosts`` file and add entries for each of the urls
above like so, assuming the IP of ``traefik`` container is ``x.x.x.x`` on its
virtual network, and you can access that address from your machine.

```properties
x.x.x.x     activemq.localhost
x.x.x.x     blazegraph.localhost
x.x.x.x     drupal.localhost
x.x.x.x     fcrepo.localhost
x.x.x.x     matomo.localhost
```

Since Drupal passes its ``Base URL`` along to other services in AS2 as a means
of allowing them to find their way back. As well as having services like Fedora
exposed at the same URL they are accessed by the micro-services to end users. We
need to allow containers within the network to be accessible via the same URL,
though not by routing through ``traefik`` since it is and edge router.

So alias like the following are defined:

```yaml
drupal:
    image: islandora/sandbox:latest
    # ...
    networks:
      default:
        aliases:
          - drupal.localhost
```

These are set on the ``default`` network as that is the internal network (no
access to the outside) on which all containers reside.

## ETCD

The [etcd](https://github.com/etcd-io/etcd) container is a distributed reliable
key-value store, which this project uses for configuration settings and secrets.
Chosen in particular for it's existing integration with
[Kubernetes](https://kubernetes.io/docs/concepts/overview/components/#etcd).

Alternatively if removed from the [docker-compose.yml] file or explicitly not
started the containers will fall back to pulling configuration from
**environment variables**.

A convenience script is provided that allows for users to put and get key/values
from the store after it has been started. For example changing the log level of
[houdini](./houdini/README.md) to ``DEBUG``.

```bash
./commands/etcdctl.sh put /houdini/log/level DEBUG
```

Or checking what the current log level is set to (*if not set to the default, in
which case the key/value store is not used*):

```bash
./commands/etcdctl.sh get /houdini/log/level
```

## Customizing the Drupal Installation

This needs to be thought about more in-depth, and needs fleshing out. Ideally we
will provide the base image for building / deploying the Drupal image. End users
will consume these containers and provide their ``composer.json`` and
``composer.lock`` files, along with the name of the
[Drupal Installation Profile] (either the one we will provide or one they create
on their own). At the moment the [composer](./composer/README.md) project is
provided as an early example of this. Where it user the
``islandora/nginx as compose`` image to perform do the composer installation,
and ``islandora/drupal`` as the container to run the installation created in the
previous step.

Additionally more documentation is needed to describe how developers can use the
existing images for local development allowing them to create their own
``composer.json`` and ``composer.lock`` files as well as any custom modules,
themes, etc.

## Design Considerations

All of the images build by this project are derived from the
[Alpine Docker Image](https://hub.docker.com/_/alpine) which is a Linux
distribution built around ``musl`` ``libc`` and ``BusyBox``. The image is only 5
MB in size and has access to a package repository. It has been chosen for its
small size, and ease of generating custom packages (as is done in the
[imagemagick](./imagemagick/README.md) image).

The [base](./base/README.md) image includes two tools essential to the
functioning of all the images.

- [Confd](https://github.com/kelseyhightower/confd) - Configuration Management
- [S6 Overlay](https://github.com/just-containers/s6-overlay) - Process Manager / Initialization system.

### Confd

``confd`` is used for all Configuration Management, it is how images are
customized on startup and during runtime. For each Docker image there will be a
folder ``rootfs/etc/confd`` that has the following layout:

```bash
./rootfs/etc/confd
├── conf.d
│   └── file.ext.toml
├── confd.toml
└── templates
    └── file.ext.tmpl
```

``confd.toml`` Is the configuration of ``confd`` and will typically limit the
namespace from which ``confd`` will read key values. For example in ``activemq``:

```toml
backend = "env"
confdir = "/etc/confd"
log-level = "debug"
interval = 600
noop = false
prefix = "/activemq"
```

The prefix is set to ``/activemq`` which means only keys / value pairs under
this prefix can be used by templates. We restrict images by prefix to force them
to define their own settings, reducing dependencies between images, and to allow
for greater customization. For example you could have Gemini use PostgreSQL as a
backend and Drupal using MariaDB since they do not share the same Database
configuration.

The ``file.ext.toml`` and ``file.ext.tmpl`` work as a pair where the ``toml``
file defines where the template will be render to and who owns it, and the
``tmpl`` file being the template in question. Ideally these files should match
the same name of the file they are generating minus the ``toml`` or ``tmpl``
suffix. This is to make the discovery of them easier.

### S6 Overlay

From this tool we only really take advantage of two features:

- Initialization scripts (*found in ``rootfs/etc/cont-init.d``*)
- Service scripts (*found in ``rootfs/etc/services.d``*)

Initialization scripts are run when the container is started and they execute in
alphabetical order. So to control the execution order they are prefix with
numbers.

One initialization script ``01-confd-render-templates.sh`` is shared by all the
images. It does a first past render of the ``confd`` templates so subsequent
scripts can run. The rest of the scripts do the minimal steps required to get
the container into a ready state before the Service scripts start.

The services scripts have the following structure:

```bash
./rootfs/etc/services.d
└── SERVICE_NAME
    ├── finish
    └── run
```

The ``run`` script is responsible for starting the service in the
**foreground**. The ``finish`` script can perform any cleanup necessary before
stopping the service, but in general it is used to kill the container, like so:

```bash
s6-svscanctl -t /var/run/s6/services
```

There are only a few Service scripts:

- activemq
- confd
- fpm
- karaf
- mysqld
- nginx
- solr
- tomcat

Of these only ``confd`` is running in every container, it periodically listens
for changes in either ``etcd`` or the ``environment variables`` and will
re-render the templates upon any change.

### Image Hierarchy

In order to save space and reduce the amount of duplication across images, they
are arranged in a hierarchy, that roughly follows below:

```bash
├── abuild
│   └── imagemagick
└── base
    ├── java
    │   ├── activemq
    │   ├── karaf
    │   │   └── alpaca
    │   ├── solr
    │   └── tomcat
    │       ├── blazegraph
    │       ├── cantaloupe
    │       ├── fcrepo
    │       └── fits
    ├── mariadb
    └── nginx
        ├── composer
        ├── crayfish
        │   ├── gemini
        │   ├── homarus
        │   ├── houdini (consumes "imagemagick" as well during its build stage)
        │   ├── hypercube
        │   ├── milliner
        │   └── recast
        ├── crayfits
        ├── drupal
        │   └── sandbox
        └── matomo
```

[abuild](./abuild/README.md) and [imagemagick](./imagemagick/README.md) stand
outside of the hierarchy as they are use only to build packages that are
consumed by other images during their build stage.

### Folder Layout

To make reasoning about what files go where each image follows the same
filesystem layout for copying files into the image.

A folder called ``rootfs`` maps directly onto the linux filesystem of the final
image. So for example ``rootfs/opt/islandora/configs/jwt`` will be
``/opt/islandora/configs/jwt`` in the generated image.

### Build System

Gradle is used as the build system, it is setup such that it will automatically
detect which folders should be considered
[projects](https://docs.gradle.org/current/dsl/org.gradle.api.Project.html) and
what dependencies exist between them. The only caveat is
that the projects cannot be nested, though that use case does not really apply.

The dependencies are resolved by parsing the Dockerfile and looking for ``FROM``
statements to determine which images are required to build it.

This means to add a new Docker image to the project you do not need to modify
the build scripts, simply add a new folder and place your Dockerfile inside of
it and it will be discovered built in the correct order relative to the other
images.

## Design Constraints

To be able to support a wide variety of backends for ``confd``, as well as
orchestration tools, all calls to ``getv`` **must provide a default**. With the
exception of keys that do not get used unless defined like
``DRUPAL_SITE_{SITE}_NAME``. This means the whatever backend for configuration,
wether it be ``etcd``, ``consul``, or ``environment variables``, containers can
successfully start without any other container present.

This does not completely remove dependencies between containers, for example,
when the [sandbox](../docker/sandbox/README.md) starts it requires a running
[fcrepo](../docker/fcrepo/README.md) to be able to ingest nodes created by
``islandora_default`` features. In these cases an initialization script can
block until another container is available or a timeout has been reached. For
example:

```bash
local fcrepo_host="{{ getv "/fcrepo/host" "fcrepo.localhost" }}"
local fcrepo_port="{{ getv "/fcrepo/host" "80" }}"
local fcrepo_url=

# Indexing fails if port 80 is given explicitly.
if [[ "${fcrepo_port}" == "80" ]]; then
    fcrepo_url="http://${fcrepo_host}/fcrepo/rest/"
else
    fcrepo_url="http://${fcrepo_host}:${fcrepo_port}/fcrepo/rest/"
fi

#...

# Need access to Solr before we can actually import the right config.
if timeout 300 wait-for-open-port.sh "${fcrepo_host}" "${fcrepo_port}" ; then
    echo "Fcrepo Found"
else
    echo "Could not connect to Fcrepo"
    exit 1
fi
```

This allows container to start up in any order, and to be orchestrated by any tool.

## To Do

- Blazegraph isn't working
- Check if Cantaloupe is working
- Add support for multiple backends to fedora (currently only file is being used)
- Confirm all derivative generation is working and check if additional tools
  need to be build or custom builds of say `poppler utils` or some other tool,
  etc are needed (need to test against a variety of inputs for each mimetype as
  there may be some edge case).
- Change public/private key generation to not rely on shared volume use the configuration management
- Do we need to support tls for etcd? Probably not since it shouldn't be exposed outside of the network. Though would be nice.
- Change solr configuration to no rely on shared volume
- Ideally no shared volumes as then container can be more easily moved between nodes in a cluster
- Get working under ECS/EKS
- Get working with Kubernetes with auto scaling for micro-services
- Developer workflow documentation / examples

[Amazon Elastic Container Service]: https://aws.amazon.com/ecs/
[Docker Compose]: https://docs.docker.com/compose/
[docker-compose.yml]: ./docker-compose.yml
[Drupal Installation Profile]: https://www.drupal.org/docs/8/distributions/creating-distributions/how-to-write-a-drupal-8-installation-profile
[drush]: https://drushcommands.com/
[etcdctrl]: https://etcd.io/docs/v3.4.0/dev-guide/interacting_v3/
[Kubernetes]: https://kubernetes.io/
[mysql]: https://dev.mysql.com/doc/refman/8.0/en/mysql.html
