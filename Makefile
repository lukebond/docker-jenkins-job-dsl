NAME := workshop-jenkins
PKG := github.com/controlplane/$(NAME)
REGISTRY := docker.io/controlplane

SHELL := /bin/bash
BUILD_DATE := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)

CONTAINER_NAME_LATEST := $(REGISTRY)/$(NAME):latest

ifeq ($(NODAEMON), true)
	RUN_MODE := 
else
	RUN_MODE := "-d"
endif

MOUNT_VOLUME_LINE :=
ifdef HOST_REPO_PATH
	MOUNT_VOLUME_LINE=-v ${HOST_REPO_PATH}:/opt/repo
endif

MOUNT_DOCKER_LINE :=
ifeq ($(MOUNTDOCKER), true)
	MOUNT_DOCKER_LINE=-v /var/run/docker.sock:/var/run/docker.sock
endif

.PHONY: all
.SILENT:

all: help

.PHONY: build
build: ## builds a docker image
	@echo "+ $@"
	docker build . --tag ${CONTAINER_NAME_LATEST}

define pre-run
	@echo "+ pre-run"

	docker rm --force ${NAME} || true
endef

.PHONY: run
run: ## runs the last built docker image with a default pipeline
	@echo "+ $@"

	@echo ${shell pwd}

	$(pre-run)
	$(run-default)

define run-default
	docker container run ${RUN_MODE} \
		--restart always \
		${MOUNT_VOLUME_LINE} \
		${MOUNT_DOCKER_LINE} \
		--publish 8080:8080 \
		--name ${NAME} \
		"${CONTAINER_NAME_LATEST}"
endef

.PHONY: stop
stop: ## stops running container
	@echo "+ $@"
	docker rm --force "${NAME}" || true

.PHONY: clean
clean: ## deletes built image and running container
	@echo "+ $@"
	docker rm --force "${NAME}" || true
	docker rmi --force "${CONTAINER_NAME_LATEST}" || true

.PHONY: help
help: ## parse jobs and descriptions from this Makefile
	@grep -E '^[ a-zA-Z0-9_-]+:([^=]|$$)' $(MAKEFILE_LIST) \
    | grep -Ev '^help\b[[:space:]]*:' \
    | sort \
    | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

