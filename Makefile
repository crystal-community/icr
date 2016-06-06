CRYSTAL_BIN ?= $(shell which crystal)
ICR_BIN ?= $(shell which icr)
PREFIX ?= /usr/local

build:
	$(CRYSTAL_BIN) build --release -o bin/icr src/icr/cli.cr $(CRFLAGS)
clean:
	rm -f ./bin/icr
test: build
	$(CRYSTAL_BIN) spec
install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/icr $(PREFIX)/bin
reinstall: build
	cp ./bin/icr $(ICR_BIN) -rf
