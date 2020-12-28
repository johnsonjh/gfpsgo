SHELL := env -i TERM=${TERM} PATH=${PATH} HOME=${HOME} XDG_CACHE_HOME=${XDG_CACHE_HOME} $(go env) command -p sh
GO ?= go
BUILD_DIR := ./bin
BIN_DIR := /usr/local/bin
NAME := psgo
PROJECT := github.com/containers/psgo
BATS_TESTS := *.bats
GO_SRC=$(shell find . -name "*.go")

GO_BUILD=$(GO) build -v -a

GOBIN ?= $(GO)/bin

all: build

.PHONY: build
build: $(GO_SRC)
	 CGO_ENABLED=0 GO111MODULES=on $(GO_BUILD) -tags="static_build,osnetgo" -trimpath -o $(BUILD_DIR)/$(NAME) -ldflags='-w -s -buildid= -linkmode=internal'  $(PROJECT)/sample

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

.PHONY: uninstall
uninstall:
	sudo rm $(BIN_DIR)/$(NAME)
