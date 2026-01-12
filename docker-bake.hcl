ARCHES = [
  "amd64",
  "arm64",
]

IMAGES = [
  "activemq",
  "alpaca",
  "base",
  "blazegraph",
  "cantaloupe",
  "crayfish",
  "crayfits",
  "drupal",
  "fcrepo6",
  "fits",
  "handle",
  "homarus",
  "houdini",
  "hypercube",
  "imagemagick",
  "java",
  "leptonica",
  "mariadb",
  "mergepdf",
  "milliner",
  "nginx",
  "postgresql",
  "riprap",
  "scyllaridae",
  "solr",
  "test",
  "tomcat",
  "transkribus",
]

DEPENDENCIES = {
  activemq = ["java"]
  alpaca = ["base", "java"]
  blazegraph = ["tomcat"]
  cantaloupe = ["java"]
  crayfish = ["nginx"]
  crayfits = ["scyllaridae"]
  drupal = ["nginx"]
  fcrepo6 = ["tomcat"]
  fits = ["tomcat"]
  handle = ["java"]
  homarus = ["scyllaridae"]
  houdini = ["scyllaridae", "imagemagick"]
  hypercube = ["scyllaridae", "leptonica"]
  java = ["base"]
  mariadb = ["base"]
  mergepdf = ["scyllaridae", "imagemagick", "leptonica"]
  milliner = ["crayfish"]
  nginx = ["base"]
  postgresql = ["base"]
  riprap = ["nginx"]
  scyllaridae = ["base"]
  solr = ["java"]
  test = ["drupal"]
  tomcat = ["java"]
  transkribus = ["base", "imagemagick"]
}

###############################################################################
# Variables
###############################################################################
variable "REPOSITORY" {
  default = "islandora"
}

variable "CACHE_FROM_REPOSITORY" {
  default = "islandora"
}

variable "CACHE_TO_REPOSITORY" {
  default = "islandora"
}

variable "TAGS" {
  # "latest" is reserved for the most recent release.
  # "local" is to distinguish that from builds produced locally.
  # Multiple tags can be specified by using a space " " delimited list.
  default = "local"
}

variable "SOURCE_DATE_EPOCH" {
  default = "0"
}

variable "BRANCH" {
  # Must be specified for ci builds.
  # BRANCH=$(git rev-parse --abbrev-ref HEAD)
  default = ""
}

###############################################################################
# Functions
###############################################################################
function hostArch {
  params = []
  result = equal("linux/amd64", BAKE_LOCAL_PLATFORM) ? "amd64" : "arm64" # Only two platforms supported.
}

function arches {
  params = [image, suffix]
  result = equal("", suffix) ? [for arch in ARCHES: "${image}-${arch}" ] : [ for arch in ARCHES: "${image}-${arch}-${suffix}" ]
}

function dependencies {
  params = [image, suffix]
  result = { for target in DEPENDENCIES[image]: target => notequal("", suffix) ? "target:${target}-${suffix}" : "target:${target}" }
}

function targets {
  params = [suffix]
  result = [for target in IMAGES: "${target}-${suffix}" ]
}

function "tags" {
  params = [image, suffix]
  result = equal("", suffix) ? [for tag in split(" ", TAGS): "${REPOSITORY}/${image}:${tag}"] : [for tag in split(" ", TAGS): "${REPOSITORY}/${image}:${tag}-${suffix}"]
}

function "cacheFrom" {
  params = [image, arch]
  result = equal("", arch) ? [] : ["type=registry,ref=${CACHE_FROM_REPOSITORY}/cache:${image}-main-${arch}", notequal("", BRANCH) ? "type=registry,ref=${CACHE_FROM_REPOSITORY}/cache:${image}-${BRANCH}-${arch}" : ""]
}

function "cacheTo" {
  params = [image, arch]
  result = [notequal("", BRANCH) ? "type=registry,oci-mediatypes=true,mode=max,compression=estargz,compression-level=5,ref=${CACHE_TO_REPOSITORY}/cache:${image}-${BRANCH}-${arch}" : ""]
}

###############################################################################
# Groups
###############################################################################
group "default" {
  targets = IMAGES
}

group "amd64" {
  targets = targets("amd64")
}

group "arm64" {
  targets = targets("arm64")
}

###############################################################################
# Common target properties.
###############################################################################
target "common" {
  args = {
    # Required for reproducible builds.
    # Requires Buildkit 0.11+
    # See: https://reproducible-builds.org/docs/source-date-epoch/
    SOURCE_DATE_EPOCH = "${SOURCE_DATE_EPOCH}",
  }
  labels = {
    "org.opencontainers.image.url" = "https://github.com/Islandora-DevOps/isle-buildkit/"
    "org.opencontainers.image.source" = "https://github.com/Islandora-DevOps/isle-buildkit/"
  }
}

target "amd64-common" {
  platforms = ["linux/amd64"]
}

target "arm64-common" {
  platforms = ["linux/arm64"]
}

###############################################################################
# Image specific target properties.
###############################################################################
target "activemq-common" {
  inherits = ["common"]
  context = "activemq"
}

target "alpaca-common" {
  inherits = ["common"]
  context = "alpaca"
}

target "base-common" {
  inherits = ["common"]
  context = "base"
  contexts = {
    # The digest (sha256 hash) is not platform specific but the digest for the manifest of all platforms.
    # It will be the digest printed when you do: docker pull alpine:3.17.1
    # Not the one displayed on DockerHub.
    alpine = "docker-image://alpine:3.23.2@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62"
  }
}

target "blazegraph-common" {
  inherits = ["common"]
  context = "blazegraph"
}

target "cantaloupe-common" {
  inherits = ["common"]
  context = "cantaloupe"
}

target "crayfish-common" {
  inherits = ["common"]
  context = "crayfish"
}

target "crayfits-common" {
  inherits = ["common"]
  context = "crayfits"
}

target "drupal-common" {
  inherits = ["common"]
  context = "drupal"
}

target "fcrepo6-common" {
  inherits = ["common"]
  context = "fcrepo6"
}

target "fits-common" {
  inherits = ["common"]
  context = "fits"
}

target "handle-common" {
  inherits = ["common"]
  context = "handle"
}

target "homarus-common" {
  inherits = ["common"]
  context = "homarus"
}

target "houdini-common" {
  inherits = ["common"]
  context = "houdini"
}

target "hypercube-common" {
  inherits = ["common"]
  context = "hypercube"
}

target "imagemagick-common" {
  inherits = ["common"]
  context = "imagemagick"
  contexts = {
    # The digest (sha256 hash) is not platform specific but the digest for the manifest of all platforms.
    # It will be the digest printed when you do: docker pull alpine:3.17.1
    # Not the one displayed on DockerHub.
    alpine = "docker-image://alpine:3.23.2@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62"
  }
}

target "java-common" {
  inherits = ["common"]
  context = "java"
}

target "leptonica-common" {
  inherits = ["common"]
  context = "leptonica"
  contexts = {
    # The digest (sha256 hash) is not platform specific but the digest for the manifest of all platforms.
    # It will be the digest printed when you do: docker pull alpine:3.17.1
    # Not the one displayed on DockerHub.
    alpine = "docker-image://alpine:3.23.2@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62"
  }
}

target "mariadb-common" {
  inherits = ["common"]
  context = "mariadb"
}

target "mergepdf-common" {
  inherits = ["common"]
  context = "mergepdf"
}

target "milliner-common" {
  inherits = ["common"]
  context = "milliner"
}

target "nginx-common" {
  inherits = ["common"]
  context = "nginx"
}

target "postgresql-common" {
  inherits = ["common"]
  context = "postgresql"
}

target "riprap-common" {
  inherits = ["common"]
  context = "riprap"
}

target "scyllaridae-common" {
  inherits = ["common"]
  context = "scyllaridae"
}

target "solr-common" {
  inherits = ["common"]
  context = "solr"
}

target "test-common" {
  inherits = ["common"]
  context = "test"
}

target "tomcat-common" {
  inherits = ["common"]
  context = "tomcat"
}

target "transkribus-common" {
  inherits = ["common"]
  context = "transkribus"
}

###############################################################################
# Default Image targets for local builds.
###############################################################################
target "activemq" {
  inherits = ["activemq-common"]
  contexts = dependencies("activemq", "")
  cache-from = cacheFrom("activemq", hostArch())
  tags = tags("activemq", "")
}

target "alpaca" {
  inherits = ["alpaca-common"]
  contexts = dependencies("alpaca", "")
  cache-from = cacheFrom("alpaca", hostArch())
  tags = tags("alpaca", "")
}

target "base" {
  inherits = ["base-common"]
  cache-from = cacheFrom("base", hostArch())
  tags = tags("base", "")
}

target "blazegraph" {
  inherits = ["blazegraph-common"]
  contexts = dependencies("blazegraph", "")
  cache-from = cacheFrom("blazegraph", hostArch())
  tags = tags("blazegraph", "")
}

target "cantaloupe" {
  inherits = ["cantaloupe-common"]
  contexts = dependencies("cantaloupe", "")
  cache-from = cacheFrom("cantaloupe", hostArch())
  tags = tags("cantaloupe", "")
}

target "crayfish" {
  inherits = ["crayfish-common"]
  contexts = dependencies("crayfish", "")
  cache-from = cacheFrom("crayfish", hostArch())
  tags = tags("crayfish", "")
}

target "crayfits" {
  inherits = ["crayfits-common"]
  contexts = dependencies("crayfits", "")
  cache-from = cacheFrom("crayfits", hostArch())
  tags = tags("crayfits", "")
}

target "drupal" {
  inherits = ["drupal-common"]
  contexts = dependencies("drupal", "")
  cache-from = cacheFrom("drupal", hostArch())
  tags = tags("drupal", "")
}

target "fcrepo6" {
  inherits = ["fcrepo6-common"]
  contexts = dependencies("fcrepo6", "")
  cache-from = cacheFrom("fcrepo6", hostArch())
  tags = tags("fcrepo6", "")
}

target "fits" {
  inherits = ["fits-common"]
  contexts = dependencies("fits", "")
  cache-from = cacheFrom("fits", hostArch())
  tags = tags("fits", "")
}

target "handle" {
  inherits = ["handle-common"]
  contexts = dependencies("handle", "")
  cache-from = cacheFrom("handle", hostArch())
  tags = tags("handle", "")
}

target "homarus" {
  inherits = ["homarus-common"]
  contexts = dependencies("homarus", "")
  cache-from = cacheFrom("homarus", hostArch())
  tags = tags("homarus", "")
}

target "houdini" {
  inherits = ["houdini-common"]
  contexts = dependencies("houdini", "")
  cache-from = cacheFrom("houdini", hostArch())
  tags = tags("houdini", "")
}

target "hypercube" {
  inherits = ["hypercube-common"]
  contexts = dependencies("hypercube", "")
  cache-from = cacheFrom("hypercube", hostArch())
  tags = tags("hypercube", "")
}

target "imagemagick" {
  inherits = ["imagemagick-common"]
  cache-from = cacheFrom("imagemagick", hostArch())
  tags = tags("imagemagick", "")
}

target "java" {
  inherits = ["java-common"]
  contexts = dependencies("java", "")
  cache-from = cacheFrom("java", hostArch())
  tags = tags("java", "")
}

target "leptonica" {
  inherits = ["leptonica-common"]
  cache-from = cacheFrom("leptonica", hostArch())
  tags = tags("leptonica", "")
}

target "mariadb" {
  inherits = ["mariadb-common"]
  contexts = dependencies("mariadb", "")
  cache-from = cacheFrom("mariadb", hostArch())
  tags = tags("mariadb", "")
}

target "mergepdf" {
  inherits = ["mergepdf-common"]
  contexts = dependencies("mergepdf", "")
  cache-from = cacheFrom("mergepdf", hostArch())
  tags = tags("mergepdf", "")
}

target "milliner" {
  inherits = ["milliner-common"]
  contexts = dependencies("milliner", "")
  cache-from = cacheFrom("milliner", hostArch())
  tags = tags("milliner", "")
}

target "nginx" {
  inherits = ["nginx-common"]
  contexts = dependencies("nginx", "")
  cache-from = cacheFrom("nginx", hostArch())
  tags = tags("nginx", "")
}

target "postgresql" {
  inherits = ["postgresql-common"]
  contexts = dependencies("postgresql", "")
  cache-from = cacheFrom("postgresql", hostArch())
  tags = tags("postgresql", "")
}

target "riprap" {
  inherits = ["riprap-common"]
  contexts = dependencies("riprap", "")
  cache-from = cacheFrom("riprap", hostArch())
  tags = tags("riprap", "")
}

target "scyllaridae" {
  inherits = ["scyllaridae-common"]
  contexts = dependencies("scyllaridae", "")
  cache-from = cacheFrom("scyllaridae", hostArch())
  tags = tags("scyllaridae", "")
}

target "solr" {
  inherits = ["solr-common"]
  contexts = dependencies("solr", "")
  cache-from = cacheFrom("solr", hostArch())
  tags = tags("solr", "")
}

target "test" {
  inherits = ["test-common"]
  contexts = dependencies("test", "")
  cache-from = cacheFrom("test", hostArch())
  tags = tags("test", "")
}

target "tomcat" {
  inherits = ["tomcat-common"]
  contexts = dependencies("tomcat", "")
  cache-from = cacheFrom("tomcat", hostArch())
  tags = tags("tomcat", "")
}

target "transkribus" {
  inherits = ["transkribus-common"]
  contexts = dependencies("transkribus", "")
  cache-from = cacheFrom("transkribus", hostArch())
  tags = tags("transkribus", "")
}

###############################################################################
# linux/amd64 targets.
###############################################################################
target "activemq-amd64" {
  inherits = ["activemq-common", "amd64-common"]
  contexts = dependencies("activemq", "amd64")
  cache-from = cacheFrom("activemq", "amd64")
  tags = tags("activemq", "amd64")
}

target "alpaca-amd64" {
  inherits = ["alpaca-common", "amd64-common"]
  contexts = dependencies("alpaca", "amd64")
  cache-from = cacheFrom("alpaca", "amd64")
  tags = tags("alpaca", "amd64")
}

target "base-amd64" {
  inherits = ["base-common", "amd64-common"]
  cache-from = cacheFrom("base", "amd64")
  tags = tags("base", "amd64")
}

target "blazegraph-amd64" {
  inherits = ["blazegraph-common", "amd64-common"]
  contexts = dependencies("blazegraph", "amd64")
  cache-from = cacheFrom("blazegraph", "amd64")
  tags = tags("blazegraph", "amd64")
}

target "cantaloupe-amd64" {
  inherits = ["cantaloupe-common", "amd64-common"]
  contexts = dependencies("cantaloupe", "amd64")
  cache-from = cacheFrom("cantaloupe", "amd64")
  tags = tags("cantaloupe", "amd64")
}

target "crayfish-amd64" {
  inherits = ["crayfish-common", "amd64-common"]
  contexts = dependencies("crayfish", "amd64")
  cache-from = cacheFrom("crayfish", "amd64")
  tags = tags("crayfish", "amd64")
}

target "crayfits-amd64" {
  inherits = ["crayfits-common", "amd64-common"]
  contexts = dependencies("crayfits", "amd64")
  cache-from = cacheFrom("crayfits", "amd64")
  tags = tags("crayfits", "amd64")
}

target "drupal-amd64" {
  inherits = ["drupal-common", "amd64-common"]
  contexts = dependencies("drupal", "amd64")
  cache-from = cacheFrom("drupal", "amd64")
  tags = tags("drupal", "amd64")
}

target "fcrepo6-amd64" {
  inherits = ["fcrepo6-common", "amd64-common"]
  contexts = dependencies("fcrepo6", "amd64")
  cache-from = cacheFrom("fcrepo6", "amd64")
  tags = tags("fcrepo6", "amd64")
}

target "fits-amd64" {
  inherits = ["fits-common", "amd64-common"]
  contexts = dependencies("fits", "amd64")
  cache-from = cacheFrom("fits", "amd64")
  tags = tags("fits", "amd64")
}

target "handle-amd64" {
  inherits = ["handle-common", "amd64-common"]
  contexts = dependencies("handle", "amd64")
  cache-from = cacheFrom("handle", "amd64")
  tags = tags("handle", "amd64")
}

target "homarus-amd64" {
  inherits = ["homarus-common", "amd64-common"]
  contexts = dependencies("homarus", "amd64")
  cache-from = cacheFrom("homarus", "amd64")
  tags = tags("homarus", "amd64")
}

target "houdini-amd64" {
  inherits = ["houdini-common", "amd64-common"]
  contexts = dependencies("houdini", "amd64")
  cache-from = cacheFrom("houdini", "amd64")
  tags = tags("houdini", "amd64")
}

target "hypercube-amd64" {
  inherits = ["hypercube-common", "amd64-common"]
  contexts = dependencies("hypercube", "amd64")
  cache-from = cacheFrom("hypercube", "amd64")
  tags = tags("hypercube", "amd64")
}

target "imagemagick-amd64" {
  inherits = ["imagemagick-common", "amd64-common"]
  cache-from = cacheFrom("imagemagick", "amd64")
  tags = tags("imagemagick", "amd64")
}

target "java-amd64" {
  inherits = ["java-common", "amd64-common"]
  contexts = dependencies("java", "amd64")
  cache-from = cacheFrom("java", "amd64")
  tags = tags("java", "amd64")
}

target "leptonica-amd64" {
  inherits = ["leptonica-common", "amd64-common"]
  cache-from = cacheFrom("leptonica", "amd64")
  tags = tags("leptonica", "amd64")
}

target "mariadb-amd64" {
  inherits = ["mariadb-common", "amd64-common"]
  contexts = dependencies("mariadb", "amd64")
  cache-from = cacheFrom("mariadb", "amd64")
  tags = tags("mariadb", "amd64")
}

target "mergepdf-amd64" {
  inherits = ["mergepdf-common", "amd64-common"]
  contexts = dependencies("mergepdf", "amd64")
  cache-from = cacheFrom("mergepdf", "amd64")
  tags = tags("mergepdf", "amd64")
}

target "milliner-amd64" {
  inherits = ["milliner-common", "amd64-common"]
  contexts = dependencies("milliner", "amd64")
  cache-from = cacheFrom("milliner", "amd64")
  tags = tags("milliner", "amd64")
}

target "nginx-amd64" {
  inherits = ["nginx-common", "amd64-common"]
  contexts = dependencies("nginx", "amd64")
  cache-from = cacheFrom("nginx", "amd64")
  tags = tags("nginx", "amd64")
}

target "postgresql-amd64" {
  inherits = ["postgresql-common", "amd64-common"]
  contexts = dependencies("postgresql", "amd64")
  cache-from = cacheFrom("postgresql", "amd64")
  tags = tags("postgresql", "amd64")
}

target "riprap-amd64" {
  inherits = ["riprap-common", "amd64-common"]
  contexts = dependencies("riprap", "amd64")
  cache-from = cacheFrom("riprap", "amd64")
  tags = tags("riprap", "amd64")
}

target "scyllaridae-amd64" {
  inherits = ["scyllaridae-common", "amd64-common"]
  contexts = dependencies("scyllaridae", "amd64")
  cache-from = cacheFrom("scyllaridae", "amd64")
  tags = tags("scyllaridae", "amd64")
}

target "solr-amd64" {
  inherits = ["solr-common", "amd64-common"]
  contexts = dependencies("solr", "amd64")
  cache-from = cacheFrom("solr", "amd64")
  tags = tags("solr", "amd64")
}

target "test-amd64" {
  inherits = ["test-common", "amd64-common"]
  contexts = dependencies("test", "amd64")
  cache-from = cacheFrom("test", "amd64")
  tags = tags("test", "amd64")
}

target "tomcat-amd64" {
  inherits = ["tomcat-common", "amd64-common"]
  contexts = dependencies("tomcat", "amd64")
  cache-from = cacheFrom("tomcat", "amd64")
  tags = tags("tomcat", "amd64")
}

target "transkribus-amd64" {
  inherits = ["transkribus-common", "amd64-common"]
  contexts = dependencies("transkribus", "amd64")
  cache-from = cacheFrom("transkribus", "amd64")
  tags = tags("transkribus", "amd64")
}

###############################################################################
# linux/arm64 targets.
###############################################################################
target "activemq-arm64" {
  inherits = ["activemq-common", "arm64-common"]
  contexts = dependencies("activemq", "arm64")
  cache-from = cacheFrom("activemq", "arm64")
  tags = tags("activemq", "arm64")
}

target "alpaca-arm64" {
  inherits = ["alpaca-common", "arm64-common"]
  contexts = dependencies("alpaca", "arm64")
  cache-from = cacheFrom("alpaca", "arm64")
  tags = tags("alpaca", "arm64")
}

target "base-arm64" {
  inherits = ["base-common", "arm64-common"]
  cache-from = cacheFrom("base", "arm64")
  tags = tags("base", "arm64")
}

target "blazegraph-arm64" {
  inherits = ["blazegraph-common", "arm64-common"]
  contexts = dependencies("blazegraph", "arm64")
  cache-from = cacheFrom("blazegraph", "arm64")
  tags = tags("blazegraph", "arm64")
}

target "cantaloupe-arm64" {
  inherits = ["cantaloupe-common", "arm64-common"]
  contexts = dependencies("cantaloupe", "arm64")
  cache-from = cacheFrom("cantaloupe", "arm64")
  tags = tags("cantaloupe", "arm64")
}

target "crayfish-arm64" {
  inherits = ["crayfish-common", "arm64-common"]
  contexts = dependencies("crayfish", "arm64")
  cache-from = cacheFrom("crayfish", "arm64")
  tags = tags("crayfish", "arm64")
}

target "crayfits-arm64" {
  inherits = ["crayfits-common", "arm64-common"]
  contexts = dependencies("crayfits", "arm64")
  cache-from = cacheFrom("crayfits", "arm64")
  tags = tags("crayfits", "arm64")
}

target "drupal-arm64" {
  inherits = ["drupal-common", "arm64-common"]
  contexts = dependencies("drupal", "arm64")
  cache-from = cacheFrom("drupal", "arm64")
  tags = tags("drupal", "arm64")
}

target "fcrepo6-arm64" {
  inherits = ["fcrepo6-common", "arm64-common"]
  contexts = dependencies("fcrepo6", "arm64")
  cache-from = cacheFrom("fcrepo6", "arm64")
  tags = tags("fcrepo6", "arm64")
}

target "fits-arm64" {
  inherits = ["fits-common", "arm64-common"]
  contexts = dependencies("fits", "arm64")
  cache-from = cacheFrom("fits", "arm64")
  tags = tags("fits", "arm64")
}

target "handle-arm64" {
  inherits = ["handle-common", "arm64-common"]
  contexts = dependencies("handle", "arm64")
  cache-from = cacheFrom("handle", "arm64")
  tags = tags("handle", "arm64")
}

target "homarus-arm64" {
  inherits = ["homarus-common", "arm64-common"]
  contexts = dependencies("homarus", "arm64")
  cache-from = cacheFrom("homarus", "arm64")
  tags = tags("homarus", "arm64")
}

target "houdini-arm64" {
  inherits = ["houdini-common", "arm64-common"]
  contexts = dependencies("houdini", "arm64")
  cache-from = cacheFrom("houdini", "arm64")
  tags = tags("houdini", "arm64")
}

target "hypercube-arm64" {
  inherits = ["hypercube-common", "arm64-common"]
  contexts = dependencies("hypercube", "arm64")
  cache-from = cacheFrom("hypercube", "arm64")
  tags = tags("hypercube", "arm64")
}

target "imagemagick-arm64" {
  inherits = ["imagemagick-common", "arm64-common"]
  cache-from = cacheFrom("imagemagick", "arm64")
  tags = tags("imagemagick", "arm64")
}

target "java-arm64" {
  inherits = ["java-common", "arm64-common"]
  contexts = dependencies("java", "arm64")
  cache-from = cacheFrom("java", "arm64")
  tags = tags("java", "arm64")
}

target "leptonica-arm64" {
  inherits = ["leptonica-common", "arm64-common"]
  cache-from = cacheFrom("leptonica", "arm64")
  tags = tags("leptonica", "arm64")
}

target "mariadb-arm64" {
  inherits = ["mariadb-common", "arm64-common"]
  contexts = dependencies("mariadb", "arm64")
  cache-from = cacheFrom("mariadb", "arm64")
  tags = tags("mariadb", "arm64")
}

target "mergepdf-arm64" {
  inherits = ["mergepdf-common", "arm64-common"]
  contexts = dependencies("mergepdf", "arm64")
  cache-from = cacheFrom("mergepdf", "arm64")
  tags = tags("mergepdf", "arm64")
}

target "milliner-arm64" {
  inherits = ["milliner-common", "arm64-common"]
  contexts = dependencies("milliner", "arm64")
  cache-from = cacheFrom("milliner", "arm64")
  tags = tags("milliner", "arm64")
}

target "nginx-arm64" {
  inherits = ["nginx-common", "arm64-common"]
  contexts = dependencies("nginx", "arm64")
  cache-from = cacheFrom("nginx", "arm64")
  tags = tags("nginx", "arm64")
}

target "postgresql-arm64" {
  inherits = ["postgresql-common", "arm64-common"]
  contexts = dependencies("postgresql", "arm64")
  cache-from = cacheFrom("postgresql", "arm64")
  tags = tags("postgresql", "arm64")
}

target "riprap-arm64" {
  inherits = ["riprap-common", "arm64-common"]
  contexts = dependencies("riprap", "arm64")
  cache-from = cacheFrom("riprap", "arm64")
  tags = tags("riprap", "arm64")
}

target "scyllaridae-arm64" {
  inherits = ["scyllaridae-common", "arm64-common"]
  contexts = dependencies("scyllaridae", "arm64")
  cache-from = cacheFrom("scyllaridae", "arm64")
  tags = tags("scyllaridae", "arm64")
}

target "solr-arm64" {
  inherits = ["solr-common", "arm64-common"]
  contexts = dependencies("solr", "arm64")
  cache-from = cacheFrom("solr", "arm64")
  tags = tags("solr", "arm64")
}

target "test-arm64" {
  inherits = ["test-common", "arm64-common"]
  contexts = dependencies("test", "arm64")
  cache-from = cacheFrom("test", "arm64")
  tags = tags("test", "arm64")
}

target "tomcat-arm64" {
  inherits = ["tomcat-common", "arm64-common"]
  contexts = dependencies("tomcat", "arm64")
  cache-from = cacheFrom("tomcat", "arm64")
  tags = tags("tomcat", "arm64")
}

target "transkribus-arm64" {
  inherits = ["transkribus-common", "arm64-common"]
  contexts = dependencies("transkribus", "arm64")
  cache-from = cacheFrom("transkribus", "arm64")
  tags = tags("transkribus", "arm64")
}
