SHELL := sh
UPX := $(shell command -v upx || printf %s "true")
STRIP := $(shell command -v strip || printf %s "true")
STATS := $(shell command -v stat || printf %s "true")
SUDO := $(shell command -v sudo || printf %s "true")
BATS := $(shell command -v bats || printf %s "true")
CCACHE := $(shell command -v ccache || printf %s "true")
GO ?= go
BUILD_DIR := ./bin
BIN_DIR := /usr/local/bin
NAME := gfpsgo
PROJECT := go.gridfinity.dev/gfpsgo
BATS_TESTS := *.bats
GO_SRC=$(shell find . -name "*.go" | grep -v "_test.go")
GO_BUILD=$(GO) build 
GOBIN ?= $(GO)/bin

all:
	@printf %s\\n "See \"help\" for more information."
help:

.PHONY: shrink
shrink: build
	@printf %s\\n "Initial strip "
	@$(STRIP) "$(BUILD_DIR)/$(NAME)" || printf %s\\n "Error: strip failure."
	@printf %s\\n "Full strip "
	@$(STRIP) --strip-all "$(BUILD_DIR)/$(NAME)" || printf %s\\n "Error: strip failure."
	@printf %s\\n "UPX overlay-strip "
	@${UPX} --overlay=strip -qqq "$(BUILD_DIR)/$(NAME)" || printf %s\\n "Error: Compression failure."
	@printf %s\\n "UPX decompress "
	@${UPX} -d -qqq "$(BUILD_DIR)/$(NAME)" || printf %s\\n "Error: Decompression failure."
	@printf %s\\n "UPX recompress "
	@${UPX} -qqq --ultra-brute "$(BUILD_DIR)/$(NAME)" || printf %s\\n "Error: Recompression failure."
	@printf %s\\n "UPX test "
	@${UPX} -qqq -t "$(BUILD_DIR)/$(NAME)" || printf %s\\n "Error: UPX failure."
	@${STATS} -c "Binary size: %s bytes" "$(BUILD_DIR)/$(NAME)" 

.PHONY: help
help:
	@printf %s\\n "Targets: allclean, clean, build, rebuild, shrink, test, install, uninstall"

.PHONY: rebuild
rebuild: 
	@export GFPSGO_REBUILDFLAG="-a" && $(MAKE) build

.PHONY: build
build: $(GO_SRC)
	@printf %s\\n "Building $(BUILD_DIR)/$(NAME)"
	@CGO_ENABLED="1" GO111MODULES="on" $(GO_BUILD) -v ${GFPSGO_REBUILDFLAG} -trimpath -o "$(BUILD_DIR)/$(NAME)" -ldflags='-w -s -buildid= -linkmode=internal' "$(PROJECT)/cmd"
	@${STATS} -c "Binary size: %s bytes" "$(BUILD_DIR)/$(NAME)" 

.PHONY: allclean
allclean: clean
	@printf %s\\n "Removing caches... "
	@$(GO) clean -cache -testcache -modcache -x
	@$(CCACHE) -cC

.PHONY: clean
clean:
	@printf %s\\n "Removing $(BUILD_DIR) directory... "
	@rm -rf "$(BUILD_DIR)"

.PHONY: test
test:
	@printf %s\\n "Run \"make bats-test\" for integration tests, or \"make go-test\" for unit tests."

.PHONY: bats-test
bats-test: build go-test
	@printf %s\\n "(sudo required for integration testing)"
	@sudo true && $(BATS) test/$(BATS_TESTS)

.PHONY: go-test
go-test: build
	@CGO_ENABLED="1" GO111MODULES="on" $(GO) test -v -tags="leaktest" -cover -covermode="atomic" -bench="." "./..."

.PHONY: install
install: build bats-test shrink
	@sudo install -D -m755 "$(BUILD_DIR)/$(NAME)" "$(BIN_DIR)"

.PHONY: uninstall
uninstall:
	@sudo rm "$(BIN_DIR)/$(NAME)"
