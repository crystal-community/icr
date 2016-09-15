CRYSTAL_BIN ?= $(shell which crystal)
PREFIX ?= /usr/local

install:
	$(CRYSTAL_BIN) build --release -o bin/icr icr/cli.cr $(CRFLAGS)
	mkdir -p $(PREFIX)/bin
	cp ./bin/icr $(PREFIX)/bin
