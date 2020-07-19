# -------------------------------------------------------------------------------------------------------
# login first (Registry: e.g., hub.docker.io, registry.localhost:5000, etc.)
# a.)  docker login
# or
# b.) sudo docker login -p FpXM6Qy9vVL5kPeoefzxwA-oaYb-Wpej2iXTwV7UHYs -e unused -u unused docker-registry-default.openkbs.org
# e.g. (using Openshift)
#    oc process -f ./files/deployments/template.yml -v API_NAME=$(REGISTRY_IMAGE) > template.active
#
# to run:
# make <verb> [ APP_VERSION=<...> DOCKER_NAME=<...> REGISTRY_HOST=<...> ]
# example:
#   make build
#   make up
#   make down
# -------------------------------------------------------------------------------------------------------

SHELL := /bin/bash

BASE_IMAGE := $(BASE_IMAGE)

## -- To Check syntax:
#  cat -e -t -v Makefile

# The name of the container (default is current directory name)
#DOCKER_NAME := $(shell echo $${PWD\#\#*/})
DOCKER_NAME := $(shell echo $${PWD\#\#*/}|tr '[:upper:]' '[:lower:]'|tr "/: " "_" )

ORGANIZATION=$(shell echo $${ORGANIZATION:-openkbs})
APP_VERSION=$(shell echo $${APP_VERSION:-latest})
imageTag=$(ORGANIZATION)/$(DOCKER_NAME)

## Docker Registry (Private Server)
REGISTRY_HOST=
#REGISTRY_HOST=$(shell echo $${REGISTRY_HOST:-localhost:5000})
REGISTRY_IMAGE=$(REGISTRY_HOST)/$(ORGANIZATION)/$(DOCKER_NAME)

#VERSION?="$(APP_VERSION)-$$(date +%Y%m%d)"
VERSION?="$(APP_VERSION)"

## -- Uncomment this to use local Registry Host --
DOCKER_REPO := $(ORGANIZATION)/$(DOCKER_NAME)

## -- To Check syntax:
#  cat -e -t -v Makefile

# -- example --
#VOLUME_MAP := "-v $${PWD}/data:/home/developer/data -v $${PWD}/workspace:/home/developer/workspace"
VOLUME_MAP := 

# -- Local SAVE of image --
IMAGE_EXPORT_PATH := "$${PWD}/archive"

# { no, on-failure, unless-stopped, always }
RESTART_OPTION := always

SHA := $(shell git describe --match=NeVeRmAtCh --always --abbrev=40 --dirty=*)

.PHONY: clean rmi build push pull up down run stop exec

clean:
	echo $(DOCKER_NAME) $(DOCKER_REPO)/$(DOCKER_NAME):$(VERSION) 

default: build

build:
	sudo docker build \
	--build-arg BASE_IMAGE="$(BASE_IMAGE)" \
	--build-arg CIRCLE_SHA1="$(SHA)" \
	--build-arg version=$(VERSION) \
	--build-arg VCS_REF=`git rev-parse --short HEAD` \
	--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	-t $(DOCKER_REPO)/$(DOCKER_NAME):$(VERSION) .

push: build
	sudo docker commit -m "$comment" ${containerID} ${imageTag}:$(VERSION)
	sudo docker push $(DOCKER_REPO)/$(DOCKER_NAME):$(VERSION)

	docker tag $(imageTag):$(VERSION) $(REGISTRY_IMAGE):$(VERSION)
	#sudo docker tag $(imageTag):latest $(REGISTRY_IMAGE):latest
	docker push $(REGISTRY_IMAGE):$(VERSION)
	#sudo docker push $(REGISTRY_IMAGE):latest
	@if [ ! "$(IMAGE_EXPORT_PATH)" = "" ]; then \
		mkdir -p $(IMAGE_EXPORT_PATH); \
		sudo docker save $(REGISTRY_IMAGE):$(VERSION) | gzip > $(IMAGE_EXPORT_PATH)/$(DOCKER_NAME)_$(VERSION).tar.gz; \
	fi
pull:
	@if [ "$(REGISTRY_HOST)" = "" ]; then \
		sudo docker pull $(DOCKER_REPO)/$(DOCKER_NAME):$(VERSION) ; \
	else \
		sudo docker pull $(REGISTRY_IMAGE):$(VERSION) ; \
	fi


up: build
	sudo docker-compose up -d

down:
	sudo docker-compose down

run:
	sudo docker run --name=$(DOCKER_NAME) --restart=$(RESTART_OPTION) $(VOLUME_MAP) $(DOCKER_REPO)/$(DOCKER_NAME):$(VERSION)

stop: run
	sudo docker stop --name=$(DOCKER_NAME)

status:
	sudo docker ps

rmi:
	sudo docker rmi $$(docker images -f dangling=true -q)

exec: up
	sudo docker-compose exec $(DOCKER_NAME) /bin/bash
