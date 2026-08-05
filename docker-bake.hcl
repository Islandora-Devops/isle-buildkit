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
  "crayfits",
  "drupal",
  "fcrepo",
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
  "scyllaridae",
  "solr",
  "test",
  "tomcat",
  "transcriber",
  "transkribus",
]

DEPENDENCIES = {
  activemq = ["java"]
  alpaca = ["base", "java"]
  blazegraph = ["tomcat"]
  cantaloupe = ["java"]
  crayfits = ["scyllaridae"]
  drupal = ["nginx"]
  fcrepo = ["tomcat", "java"]
  fits = ["tomcat"]
  handle = ["java"]
  homarus = ["scyllaridae"]
  houdini = ["scyllaridae", "imagemagick"]
  hypercube = ["scyllaridae", "leptonica"]
  java = ["base"]
  mariadb = ["base"]
  mergepdf = ["scyllaridae", "leptonica"]
  milliner = ["nginx"]
  nginx = ["base"]
  postgresql = ["base"]
  scyllaridae = ["base"]
  solr = ["java"]
  test = ["drupal"]
  tomcat = ["java"]
  transcriber = ["base", "scyllaridae"]
  transkribus = ["base", "imagemagick"]
}

# Named build contexts that are not other targets in this file.
ALPINE_CONTEXT = "docker-image://alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b"
IMAGE_CONTEXTS = {
  for image in ["base", "imagemagick", "leptonica"] :
  image => { alpine = ALPINE_CONTEXT }
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
function "hostArch" {
  params = []
  # Only two platforms are supported.
  result = equal("linux/amd64", BAKE_LOCAL_PLATFORM) ? "amd64" : "arm64"
}

function "targetName" {
  params = [image, arch]
  result = equal("", arch) ? image : "${image}-${arch}"
}

function "dependencies" {
  params = [image, arch]
  result = {
    for dependency in lookup(DEPENDENCIES, image, []) :
    dependency => "target:${targetName(dependency, arch)}"
  }
}

function "targets" {
  params = [arch]
  result = [for image in IMAGES : targetName(image, arch)]
}

function "tags" {
  params = [image, arch]
  result = equal("", arch) ? [for tag in split(" ", TAGS) : "${REPOSITORY}/${image}:${tag}"] : [for tag in split(" ", TAGS) : "${REPOSITORY}/${image}:${tag}-${arch}"]
}

function "cacheFrom" {
  params = [image, arch]
  result = equal("", arch) ? [] : ["type=registry,ref=${CACHE_FROM_REPOSITORY}/cache:${image}-main-${arch}", notequal("", BRANCH) ? "type=registry,ref=${CACHE_FROM_REPOSITORY}/cache:${image}-${BRANCH}-${arch}" : ""]
}

function "cacheTo" {
  params = [image, arch]
  result = [notequal("", BRANCH) ? "type=registry,oci-mediatypes=true,mode=max,compression=estargz,compression-level=5,ref=${CACHE_TO_REPOSITORY}/cache:${image}-${BRANCH}-${arch}" : ""]
}

function "context" {
  params = [image]
  result = "images/${image}"
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
# Targets
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

# Bake matrices are the supported way to generate target blocks. This creates
# each image's native, linux/amd64, and linux/arm64 targets from the metadata
# above while keeping names such as `milliner` and `milliner-amd64` stable.
target "_images" {
  name = targetName(image, arch)
  matrix = {
    image = IMAGES
    arch = concat([""], ARCHES)
  }

  inherits = ["common"]
  context = context(image)
  contexts = merge(lookup(IMAGE_CONTEXTS, image, {}), dependencies(image, arch))
  platforms = equal("", arch) ? [] : ["linux/${arch}"]
  cache-from = cacheFrom(image, equal("", arch) ? hostArch() : arch)
  tags = tags(image, arch)
}
