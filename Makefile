# Display help by default.
.DEFAULT_GOAL := help

# Require bash to use foreach loops.
SHELL := bash

# For text display in the shell.
RESET = $(shell tput sgr0)
RED = $(shell tput setaf 9)
BLUE = $(shell tput setaf 6)
TARGET_MAX_CHAR_NUM = 30

# Some targets will only be included if the appropriate condition is met.
SSH_AGENT_RUNNING := $(shell test -S "$${SSH_AUTH_SOCK}" && echo "true")

# For some commands we must invoke a Windows executable if in the context of WSL.
IS_WSL := $(shell grep -q WSL /proc/version 2>/dev/null && echo "true")

# Use the host mkcert.exe if executing make from WSL context.
MKCERT := $(if $(filter true,$(IS_WSL)),mkcert.exe,mkcert)

# The location of root certificates.
CAROOT := $(if $(filter true,$(IS_WSL)),$(shell $(MKCERT) -CAROOT | xargs -0 wslpath -u),$(shell $(MKCERT) -CAROOT))

# Display text for requirements.
README_MESSAGE = ${BLUE}Consult the README.md for how to install requirements.${RESET}\n

# Bash snippet to check for the existance an executable.
define executable-exists
	@if ! command -v $(1) >/dev/null; \
	then \
		printf "${RED}Could not find executable: %s${RESET}\n${README_MESSAGE}" $(1); \
		exit 1; \
	fi
endef

# Used to include host-platform specific docker compose files.
OS := $(shell uname -s | tr A-Z a-z)

# Used to determine set TAGS when no explicit value provided,
# as well as to fetch branch specific remote caches when building.
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)

# The buildkit builder to use.
BUILDER ?= default

# Were to push/pull from.
REPOSITORY ?= islandora

PROGRESS ?= auto

# Were to push/pull cache from.
CACHE_FROM_REPOSITORY ?= $(REPOSITORY)
CACHE_TO_REPOSITORY ?= $(REPOSITORY)

# Tags to apply to all images loaded or pushed, space delimited.
TAGS ?= local

# Targets in `docker-bake.hcl` to build if requested.
TARGET ?= default

# Contexts can be used to override bake contexts when building
# reducing build times, etc. See the GitHub actions for an example.
CONTEXTS ?=

# All images should be included in the bake files default target.
# It is the source of truth.
ALL_IMAGES = $(shell docker buildx bake --print default 2>/dev/null | jq -r '.target[].context')
TARGET_IMAGES = $(shell docker buildx bake --print $(TARGET) 2>/dev/null | jq -r '.target[].context')

build:
	mkdir -p build

# This is a catch all target that is used to check for existance of an
# executable when declared as a dependency.
.PHONY: %
%:
	$(call executable-exists,$@)

# Prior to building, all folders which might be copied into Docker images must
# have the executable bit set for all users. So that they can be read by the
# users we create like 'tomcat'. We can not insure this via Git as it does 
# not track permissions for folders, so we rely on this hack.
.PHONY: folder-permissions
folder-permissions:
	find images -type d -exec chmod +x {} \;

# Prior to building, all scripts which might be copied into Docker images must
# have the executable bit set for all users. So that they can be executed by
# the users we create like 'nginx'. We can not insure this via Git as it does
# not track executable permissions for "groups" or "others".
.PHONY: executable-permissons
executable-permissons:
	find images -type f \
    \( \
      -name "*.sh" \
      -o -name "run" \
      -o -name "check" \
      -o -name "finish" \
      -o -name "bash.bashrc" \
      -o -name "drush" \
      -o -name "composer" \
    \) \
    -exec chmod +rx {} \;

# Checks for docker compose plugin.
.PHONY: docker-compose
docker-compose: MISSING_DOCKER_PLUGIN_MESSAGE = ${RED}docker compose plugin is not installed${RESET}\n${README_MESSAGE}
docker-compose: | docker
  # Check for `docker compose` as compose version 2+ is used is assumed.
	@if ! docker compose version &>/dev/null; \
	then \
		printf "$(MISSING_DOCKER_PLUGIN_MESSAGE)"; \
		exit 1; \
	fi

# Checks for docker buildx plugin.
.PHONY: docker-buildx
docker-buildx: MISSING_DOCKER_BUILDX_PLUGIN_MESSAGE = ${RED}docker buildx plugin is not installed${RESET}\n${README_MESSAGE}
docker-buildx: | docker
  # Check for `docker buildx` as we do not support building without it.
	@if ! docker buildx version &>/dev/null; \
	then \
		printf "$(MISSING_DOCKER_BUILDX_PLUGIN_MESSAGE)"; \
		exit 1; \
	fi

.git/hooks/pre-commit: | pre-commit
.git/hooks/pre-commit:
	pre-commit install

.PHONY: login
login: REGISTRIES = https://index.docker.io/v1/
login: | docker jq
login:
	@for registry in $(REGISTRIES); \
	do \
		if ! jq -e ".auths|keys|any(. == \"$$registry\")" ~/.docker/config.json &>/dev/null; \
		then \
			printf "Log into $$registry\n"; \
			docker login $$registry; \
		fi \
	done

$(CAROOT)/rootCA-key.pem $(CAROOT)/rootCA.pem &: | $(MKCERT)
  # Requires mkcert to be installed first (It may fail on some systems due to how Java is configured, but this can be ignored).
	-$(MKCERT) -install

# Using mkcert to generate local certificates rather than traefik certs
# as they often get revoked.
build/certs/cert.pem build/certs/privkey.pem build/certs/rootCA.pem build/certs/rootCA-key.pem &: $(CAROOT)/rootCA-key.pem $(CAROOT)/rootCA.pem | $(MKCERT) build
	mkdir -p build/certs
	$(MKCERT) -cert-file build/certs/cert.pem -key-file build/certs/privkey.pem \
		"*.islandora.dev" \
		"islandora.dev" \
		"*.islandora.io" \
		"islandora.io" \
		"*.islandora.info" \
		"islandora.info" \
		"localhost" \
		"127.0.0.1" \
		"::1"
	cp "$(CAROOT)/rootCA-key.pem" build/certs/rootCA-key.pem
	cp "$(CAROOT)/rootCA.pem" build/certs/rootCA.pem

build/certs/tls.crt: build/certs/rootCA.pem
	cp build/certs/rootCA.pem build/certs/tls.crt

build/certs/tls.key: build/certs/rootCA-key.pem
	cp build/certs/rootCA-key.pem build/certs/tls.key

.PHONY: certs
## Generate certificates required for using docker compose.
certs: build/certs/tls.crt build/certs/tls.key

# When doing local development it is preferable to have the containers nginx
# user have the same uid/gid as the host machine to prevent permission issues.
build/secrets/UID build/secrets/GID &: | id build
	mkdir -p build/secrets
	id -u > build/secrets/UID
	id -g > build/secrets/GID

# Mounting SSH-Agent socket is platform dependent.
docker-compose.override.yml:
	@if [[ -S "$${SSH_AUTH_SOCK}" ]]; then \
		cp docker-compose.$(OS).yml docker-compose.override.yml; \
	fi

# Prior to building we export the plan and then update it to include contexts,
# etc provided by the environment / user.
# Despite being a real target we make it PHONY so it is run everytime as $(TARGET) can change.
.PHONY: build/bake.json
.SILENT: build/bake.json
build/bake.json: | docker-buildx jq build folder-permissions executable-permissons
  # Generate build plan for the given target and update the contexts if provided by the CI.
	BRANCH=$(BRANCH) \
	CACHE_FROM_REPOSITORY=$(CACHE_FROM_REPOSITORY) \
	CACHE_TO_REPOSITORY=$(CACHE_TO_REPOSITORY) \
	REPOSITORY=$(REPOSITORY) \
	TAGS="$(TAGS)" \
	docker buildx bake --print $(TARGET) 2>/dev/null > build/bake.json; \
	for context in $(CONTEXTS); \
	do \
		context_image=$$(sed 's/^docker-image:\/\/[^\/]*\/\([^\/@:]*\).*/\1/' <<< $${context}); \
		jq "walk(if type == \"object\" and .contexts.$${context_image} then .contexts.$${context_image} = \"$${context}\" else . end)" build/bake.json > build/tmp.bake.json; \
		cp build/tmp.bake.json build/bake.json; \
		rm build/tmp.bake.json; \
	done
  # Remove unreferenced targets, as they complicate generating the manifest, etc.
	docker buildx bake --print -f build/bake.json 2>/dev/null > build/tmp.bake.json
	cp build/tmp.bake.json build/bake.json
	rm build/tmp.bake.json

.SILENT: build/manifests.json
build/manifests.json: build/bake.json
	jq '[.target[].tags[]] | reduce .[] as $$i ({}; .[$$i | sub("-(arm64|amd64)$$"; "")] = ([$$i] + .[$$i | sub("-(arm64|amd64)$$"; "")] | sort))' build/bake.json > build/manifests.json

.PHONY: bake
## Builds and loads the target(s) into the local docker context.
bake: build/bake.json
	docker buildx bake --builder $(BUILDER) -f build/bake.json --progress=$(PROGRESS) --load

.PHONY: push
## Builds and pushes the target(s) into remote repository.
push: build/bake.json login
push:
	docker buildx bake --builder $(BUILDER) -f build/bake.json --progress=$(PROGRESS) --push

.PHONY: manifest
## Creates manifest for multi-arch images.
manifest: build/manifests.json $(filter push,$(MAKECMDGOALS)) | jq
  # Since this is only really used by the Github Actions it's built to assume a single target at a time.
	MANIFESTS=(); \
	while IFS= read -r line; do \
			MANIFESTS+=( "$$line" ); \
	done < <(jq -r '. | to_entries | reduce .[] as $$i ([]; . + ["\($$i.key) \($$i.value | join(" "))"]) | .[]' build/manifests.json); \
	for args in "$${MANIFESTS[@]}"; \
	do \
		docker buildx imagetools create -t $${args}; \
	done
  # After creating the manifests we can fetch the digests to use as contexts in later builds.
	DIGESTS=(); \
	while IFS= read -r line; do \
		DIGESTS+=( "$$line" ); \
	done < <(jq -r 'keys | reduce .[] as $$i ({}; .[$$i | sub("^[^/]+/(?<x>[^@:]+).*$$"; "\(.x)")] = $$i) | to_entries[] | "\(.key) \(.value)"' build/manifests.json); \
	for digest in "$${DIGESTS[@]}"; \
	do \
		args=($${digest}); \
		context=$${args[0]}; \
		image=$${args[1]}; \
		docker buildx imagetools inspect --raw $${image} | shasum -a 256 | cut -f1 -d' ' | tr -d '\n' > build/$${context}.digest; \
	done

.PHONY: up
## Starts up the local development environment.
up: build/certs/cert.pem build/certs/privkey.pem build/certs/rootCA.pem
up: build/secrets/UID build/secrets/GID
up: $(if $(filter true,$(SSH_AGENT_RUNNING)),docker-compose.override.yml)
up: $(filter down,$(MAKECMDGOALS))
up: bake | docker-compose
  # jetbrains cache / config is created externally so it will persist indefinitely.
	docker volume create jetbrains-cache
	docker volume create jetbrains-config
	docker compose up -d
	@printf "Waiting for installation..."
	@docker compose exec drupal timeout 600 bash -c "while ! test -f /installed; do sleep 5; done"
	@printf "  Credentials:\n"
	@printf "  ${RED}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${BLUE}%s${RESET}\n" "Username" "admin"
	@printf "  ${RED}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${BLUE}%s${RESET}\n" "Password" "password"
	@printf "\n  Services Available:\n"
	@for link in \
		"Drupal|https://islandora.dev" \
		"IDE|https://ide.islandora.dev" \
		"ActiveMQ|https://activemq.islandora.dev" \
		"Blazegraph|https://blazegraph.islandora.dev/bigdata/" \
		"Fedora|https://fcrepo.islandora.dev/fcrepo/rest/" \
		"Cantaloupe|https://islandora.dev/cantaloupe" \
		"Solr|https://solr.islandora.dev" \
		"Traefik|https://traefik.islandora.dev" \
	; \
	do \
		echo $$link | tr -s '|' '\000' | xargs -0 -n2 printf "  ${RED}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${BLUE}%s${RESET}"; \
	done

.PHONY: stop
## Stops the local development environment.
stop: | docker-compose
	docker compose stop

.PHONY: down
## Stops the local development environment and destroys volumes.
down: | docker-compose
	docker compose down -v

.PHONY: clean
## Destroys local environment and cleans up any uncommitted files.
clean: down | git
	git clean -xfd .

.PHONY: setup
## Checks that all required tools are installed (Installs pre-commit).
setup: .git/hooks/pre-commit | git docker-compose docker-buildx jq awk $(MKCERT)

.PHONY: help
.SILENT: help
## Displays this help message.
help: | awk
	@echo ''
	@echo 'Usage:'
	@echo '  ${RED}make${RESET} ${BLUE}<target>${RESET}'
	@echo ''
	@echo 'BuildKit:'
	@awk '/^[a-zA-Z\-_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; sub(/:$$/, "", helpCommand); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			if (helpCommand == "bake" || helpCommand == "push" || helpCommand == "manifest") { \
				printf "  ${RED}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${BLUE}%s${RESET}\n", helpCommand, helpMessage; \
			} \
		} \
	} \
	{lastLine = $$0}' $(MAKEFILE_LIST)
	@echo ''
	@echo 'Compose:'
	@awk '/^[a-zA-Z\-_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; sub(/:$$/, "", helpCommand); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			if (helpCommand == "certs" || helpCommand == "up" || helpCommand == "stop" || helpCommand == "down") { \
				printf "  ${RED}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${BLUE}%s${RESET}\n", helpCommand, helpMessage; \
			} \
		} \
	} \
	{lastLine = $$0}' $(MAKEFILE_LIST)
	@echo ''
	@echo 'General:'
	@awk '/^[a-zA-Z\-_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; sub(/:$$/, "", helpCommand); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			if (helpCommand == "setup" || helpCommand == "clean" || helpCommand == "help" || helpCommand == "test") { \
				printf "  ${RED}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${BLUE}%s${RESET}\n", helpCommand, helpMessage; \
			} \
		} \
	} \
	{lastLine = $$0}' $(MAKEFILE_LIST)
	@echo ''
