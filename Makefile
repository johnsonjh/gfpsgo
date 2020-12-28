SHELL := env -i TERM=${TERM} PATH=${PATH} HOME=${HOME} XDG_CACHE_HOME=${XDG_CACHE_HOME} $(go env) command -p sh
UPX := $(shell env command -v upx || printf %s "true")
GO ?= go
BUILD_DIR := ./bin
BIN_DIR := /usr/local/bin
NAME := psgo
PROJECT := github.com/containers/psgo
BATS_TESTS := *.bats
GO_SRC=$(shell find . -name "*.go")

GO_BUILD=$(GO) build -v -a

GOBIN ?= $(GO)/bin

all: build compress

.PHONY: compress
compress:
	@printf %s\\n "UPX Compressing $(BUILD_DIR)/$(NAME)..."
	@${UPX} --overlay=strip -qq --ultra-brute $(BUILD_DIR)/$(NAME) || printf %s\\n "Error: Compression failure."
	@printf %s\\n "Decompressing $(BUILD_DIR)/$(NAME)..."
	@${UPX} -d -qq $(BUILD_DIR)/$(NAME) || printf %s\\n "Error: Compression failure."
	@printf %s\\n "Recompressing $(BUILD_DIR)/$(NAME)..."
	@${UPX} -qq --exact --ultra-brute $(BUILD_DIR)/$(NAME) || printf %s\\n "Error: Compression failure."
	@printf %s\\n "Testing compressed $(BUILD_DIR)/$(NAME)..."
	@${UPX} -qq -t $(BUILD_DIR)/$(NAME) && printf %s\\n "OK!" || printf %s\\n "Error: Compression failure."

.PHONY: build
build: $(GO_SRC)
	 CGO_ENABLED=1 GO111MODULES=on $(GO_BUILD) -tags="static_build,osnetgo" -trimpath -o $(BUILD_DIR)/$(NAME) -ldflags='-w -s -buildid= -linkmode=internal'  $(PROJECT)/sample

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
