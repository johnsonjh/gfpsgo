SHELL := env -i TERM=${TERM} PATH=${PATH} HOME=${HOME} XDG_CACHE_HOME=${XDG_CACHE_HOME} $(go env) command -p sh
UPX := $(shell env command -v upx || printf %s "true")
GO ?= go
BUILD_DIR := ./bin
BIN_DIR := /usr/local/bin
NAME := gfpsgo
PROJECT := go.gridfinity.dev/gfpsgo
BATS_TESTS := *.bats
GO_SRC=$(shell find . -name "*.go" | grep -v "_test.go")

GO_BUILD=$(GO) build -v -a

GOBIN ?= $(GO)/bin

all:
	@printf %s\\n "See \"help\" for more information."
help:

.PHONY: compress
compress:
	@printf %s\\n "Stripping $(BUILD_DIR)/$(NAME)..."
	@strip --strip-all $(BUILD_DIR)/$(NAME) || printf %s\\n "Error: strip failure."
	@printf %s\\n "Compressing $(BUILD_DIR)/$(NAME)..."
	@${UPX} --overlay=strip -qq --ultra-brute $(BUILD_DIR)/$(NAME) || printf %s\\n "Error: Compression failure."
	@printf %s\\n "Decompressing $(BUILD_DIR)/$(NAME)..."
	@${UPX} -d -qq $(BUILD_DIR)/$(NAME) || printf %s\\n "Error: Decompression failure."
	@printf %s\\n "Recompressing $(BUILD_DIR)/$(NAME)..."
	@${UPX} -qq --exact --ultra-brute $(BUILD_DIR)/$(NAME) || printf %s\\n "Error: Recompression failure."
	@printf %s\\n "Testing compressed $(BUILD_DIR)/$(NAME)..."
	@${UPX} -qq -t $(BUILD_DIR)/$(NAME) && printf %s\\n "OK!" || printf %s\\n "Error: Compression failure."

.PHONY: help
help:
	@printf %s\\n "Targets: help, clean, build, compress, test, check, install, uninstall"

.PHONY: build
build: $(GO_SRC)
	 @CGO_ENABLED=1 GO111MODULES=on $(GO_BUILD) -tags="static_build,osnetgo" -trimpath -o $(BUILD_DIR)/$(NAME) -ldflags='-w -s -buildid= -linkmode=internal'  $(PROJECT)/sample

.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)

.PHONY: test
test:
	@printf %s\\n "Run \"make bats-test\" for integration tests, or \"make go-test\" for unit tests."

.PHONY: bats-test
bats-test: 
	@bats test/$(BATS_TESTS)

.PHONY: go-test
go-test: 
	@GOMAXPROCS=128 $(GO) test -cpu=12 -parallel=2 -count=2 -v -race -tags=leaktest -cover -covermode=atomic -bench=. "./..."

.PHONY: install
install:
	@sudo install -D -m755 $(BUILD_DIR)/$(NAME) $(BIN_DIR)

.PHONY: uninstall
uninstall:
	@sudo rm $(BIN_DIR)/$(NAME)
