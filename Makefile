GO := go
pkgs   = $(shell basename `git rev-parse --show-toplevel`)
VERSION ?=$(shell git describe --abbrev=0)
BUILD ?=$(shell date +%FT%T%z)
GOVERSION ?=$(shell go version | cut --delimiter=" " -f3)
COMMIT ?=$(shell git rev-parse HEAD)
BRANCH ?=$(shell git rev-parse --abbrev-ref HEAD)

PREFIX=$(shell pwd)
TOP_DIR=$(shell git rev-parse --show-toplevel)
BIN_DIR=$(shell git rev-parse --show-toplevel)/bin
SRC_DIR=$(shell git rev-parse --show-toplevel)/src/go
LDFLAGS="-X main.Version=${VERSION} -X main.Build=${BUILD} -X main.Commit=${COMMIT} -X main.Branch=${BRANCH} -X main.GoVersion=${GOVERSION} -s -w"

.PHONY: all style format build test vet tarball linux-amd64

all: clean linux-amd64 darwin-amd64

clean:
	@echo "Cleaning binaries dir ${BIN_DIR}"
	@rm -rf ${BIN_DIR}/ 2> /dev/null

linux-amd64: 
	@echo "Building linux/amd64 binaries in ${BIN_DIR}"
	@mkdir -p ${BIN_DIR}
	@rm -f ${BIN_DIR}/mysql_random_data_loader_linux_amd64.tar.gz
	@GOOS=linux GOARCH=amd64 go build -ldflags ${LDFLAGS} -o ${BIN_DIR}/mysql_random_data_loader cmd/main.go
	@tar cvzf ${BIN_DIR}/mysql_random_data_loader_linux_amd64.tar.gz -C ${BIN_DIR} mysql_random_data_loader


linux-386: 
	@echo "Building linux/386 binaries in ${BIN_DIR}"
	@mkdir -p ${BIN_DIR}
	@rm -f ${BIN_DIR}/mysql_random_data_loader_linux_386.tar.gz
	@GOOS=linux GOARCH=386 go build -ldflags ${LDFLAGS} -o ${BIN_DIR}/mysql_random_data_loader cmd/main.go
	@tar cvzf ${BIN_DIR}/mysql_random_data_loader_linux_386.tar.gz -C ${BIN_DIR} mysql_random_data_loader

darwin-amd64: 
	@echo "Building darwin/amd64 binaries in ${BIN_DIR}"
	@mkdir -p ${BIN_DIR}
	@rm -f ${BIN_DIR}/mysql_random_data_loader_darwin_amd64.tar.gz
	@GOOS=darwin GOARCH=amd64 go build -ldflags ${LDFLAGS} -o ${BIN_DIR}/mysql_random_data_loader cmd/main.go
	@tar cvzf ${BIN_DIR}/mysql_random_data_loader_darwin_amd64.tar.gz -C ${BIN_DIR} mysql_random_data_loader

style:
	@echo ">> checking code style"
	@! gofmt -d $(shell find . -path ./vendor -prune -o -name '*.go' -print) | grep '^'

test:
	@echo ">> running tests"
	@./runtests.sh

format:
	@echo ">> formatting code"
	@$(GO) fmt $(pkgs)

vet:
	@echo ">> vetting code"
	@$(GO) vet $(pkgs)

