#
# Makefile for this application
#

REPO_URL ?=
IMAGE_NAME ?=
USER_NAME ?= grengojbo
ADMIN_USER ?= grengojbo
TAG_VERSION=$(shell cat RELEASE)
OSNAME=$(shell uname)

GO=$(shell which go)

CUR_TIME=$(shell date '+%Y-%m-%d_%H:%M:%S')
# Program version
VERSION=$(shell cat RELEASE)

# Project name for bintray
PROJECT_NAME=$(shell basename $(abspath ./))
PROJECT_DIR=$(shell pwd)

# Grab the current commit
GIT_COMMIT=$(shell git rev-parse HEAD)

# Check if there are uncommited changes
GIT_DIRTY="$(shell test -n "`git status --porcelain`" && echo "+CHANGES" || true)"

DIST_DIR="${PROJECT_DIR}/bin"

NAME ?= ${PROJECT_NAME}

BUILD_TAGS ?= "netgo"
BUILD_TAGS_BINDATA ?= netgo
BUILD_ENV = GOOS=linux GOARCH=amd64
ENVFLAGS = CGO_ENABLED=1 $(BUILD_ENV)

GO_LINKER_FLAGS ?= -ldflags '-s -w \
  -X "main.BuildTime=${CUR_TIME}" \
  -X "main.Version=${VERSION}" \
  -X "main.GitHash=${GIT_COMMIT}"

default: help

help:
	@echo "..............................................................."
	@echo "Project: $(PROJECT_NAME) | current dir: $(PROJECT_DIR)"
	@echo "version: $(VERSION)\n"
	@echo "make init        - Load godep"
	@echo "make clean       - Clean .orig, .log files"
	@echo "make build       - Build for current OS project"
	@echo "make build-linux - Build for Linux project"
	@echo "make version     - Current project version"
	@echo "...............................................................\n"

init:
	@go get -u -v
	@go get -u golang.org/x/vgo

clean:
	@test ! -e ./${NAME} || rm ./${NAME}
	@#git gc --prune=0 --aggressive
	@find . -name "*.orig" -type f -delete
	@find . -name "*.log" -type f -delete
	@test ! -e ${DIST_DIR}/${NAME} || rm -R ${DIST_DIR}/${NAME}

build: clean
	@mkdir -p $(DIST_DIR)
	@echo "building version: ${VERSION} to  ${DIST_DIR}/${NAME}"
	@CGO_ENABLED=1 go build -a -installsuffix cgo -tags $(BUILD_TAGS_BINDATA) $(GO_LINKER_FLAGS)' -o ./$(NAME) main.go
	@echo " "

build-linux: clean
	@mkdir -p $(DIST_DIR)
	@echo "building version: ${VERSION} to  ${DIST_DIR}/${NAME}"
	@$(ENVFLAGS) go build -a -installsuffix cgo -tags $(BUILD_TAGS_BINDATA) $(GO_LINKER_FLAGS)' -o $(DIST_DIR)/$(NAME) main.go
	@echo " "

version:
	@echo ${VERSION}
