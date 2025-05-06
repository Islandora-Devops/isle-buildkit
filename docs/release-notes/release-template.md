# Release Notes - isle-buildkit 03-2022

### Contributions to this release from:

Code updates, documentation, testing

* [Nigel Banks](https://github.com/nigelgbanks), Lead Dev
* [Don Richards](https://github.com/DonRichards)
* [Jeffrey Antoniuk](https://github.com/jefferya)
* [Gavin Morris](https://github.com/g7morris), Release Manager

### Description

* Updates for the following Gradle related software

<!--- Maintainers to pick one or more, uncomment and then remove remaining untouched images listed below --->

<!---
* gradle
* gradle.properties
* gradlew
* gradlew.bat
--->

* Security and package updates for the following Docker images
  * `apk upgrade --available` dist-upgrades for dependencies security and package updates
    * abuild
    * base
    * build
    * download

* Updates, fixes or PRs merged for the following services or Docker images

<!--->Release Manager to pull PRs from Release Sprint and copy here --->

<!--- Maintainers to manually pick one or more, uncomment and then remove remaining untouched images listed below as / if needed.

Example:

* imagemagick
  * upgraded to version `7.1.0-28`
  * Changes made to xyz. Explain important change as needed.

List of services so maintainers don't need to look this up.

activemq
alpaca
blazegraph
cantaloupe
code-server
composer
crayfish
crayfits
drupal
fcrepo6
fits
handle
homarus
houdini
hypercube
imagemagick
java
mariadb
milliner
nginx
postgresql
riprap
solr
test
tomcat
--->

#### isle-apache


* `ImageMagick` upgraded to version `7.1.0-25`
* `Apache Xerces` upgraded to `2.12.2` (_used with FITS_)
* Github Actions [workflow](https://github.com/marketplace/actions/build-and-push-docker-images) updated

#### isle-blazegraph

* ISLE Tomcat base image upgrade
* `apt-get` dist-upgrades for dependencies security and package updates
* Github Actions [workflow](https://github.com/marketplace/actions/build-and-push-docker-images) updated

#### isle-fedora

* ISLE Tomcat base image upgrade
* `apt-get` dist-upgrades for dependencies security and package updates
* Apache `Maven` **held** at version `3.6.3` despite a recent April `3.8.1` release. Breaks POM dependencies and blocks mirrors.
* Apache `Ant` **held** at version `1.10.9` despite a recent April `1.10.10` release. Upstream dependencies fail to download in Github Actions.
* Github Actions [workflow](https://github.com/marketplace/actions/build-and-push-docker-images) updated

#### isle-imageservices

* ISLE Tomcat base image upgrade
* `apt-get` dist-upgrades for dependencies security and package updates
* `ImageMagick` upgraded to version `7.1.0-25`
* Github Actions [workflow](https://github.com/marketplace/actions/build-and-push-docker-images) updated

#### isle-mysql

* `apt-get` dist-upgrades for dependencies security and package updates
* Github Actions [workflow](https://github.com/marketplace/actions/build-and-push-docker-images) updated

#### isle-solr

* ISLE Tomcat base image upgrade
* `apt-get` dist-upgrades for dependencies security and package updates
* Github Actions [workflow](https://github.com/marketplace/actions/build-and-push-docker-images) updated

#### isle-tomcat

* `apt-get` dist-upgrades for dependencies security and package updates
* Github Actions [workflow](https://github.com/marketplace/actions/build-and-push-docker-images) updated

#### isle-varnish

* `apt-get` dist-upgrades for dependencies security and package updates
* Github Actions [workflow](https://github.com/marketplace/actions/build-and-push-docker-images) updated
