export GO111MODULE=off
export GOPROXY=https://proxy.golang.org
export CGO_ENABLED=0

SHELL= env -i PATH=${PATH} HOME=${HOME} XDG_CACHE_HOME=${XDG_CACHE_HOME} $(go env) command -p sh
GO ?= go
BUILD_DIR := ./bin
BIN_DIR := /usr/local/bin
NAME := psgo
PROJECT := github.com/containers/psgo
BATS_TESTS := *.bats
GO_SRC=$(shell find . -name \*.go)

GO_BUILD=$(GO) build
ifeq ($(shell go help mod >/dev/null 2>&1 && echo true), true)
	GO_BUILD=GO111MODULE=on $(GO) build -v -x -a
endif

GOBIN ?= $(GO)/bin

all: build

.PHONY: build
build: $(GO_SRC)
	 $(GO_BUILD) -trimpath -o $(BUILD_DIR)/$(NAME) -ldflags='-w -s -buildid= ' $(PROJECT)/sample

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: test
test: test-unit test-integration

.PHONY: test-integration
test-integration:
	bats test/$(BATS_TESTS)

.PHONY: test-unit
test-unit:
	go test -v $(PROJECT)
	go test -v $(PROJECT)/internal/...

.PHONY: install
install:
	sudo install -D -m755 $(BUILD_DIR)/$(NAME) $(BIN_DIR)

.PHONY: .install.lint
.install.lint:
	VERSION=1.24.0 GOBIN=$(GOBIN) sh ./hack/install_golangci.sh

.PHONY: uninstall
uninstall:
	sudo rm $(BIN_DIR)/$(NAME)
