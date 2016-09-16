# This Makefile is only used for compiling icr 
# when added as a dependency to another project.
# This may go away in a future version if the shards postinstall command changes.
#

CRYSTAL_BIN ?= $(shell which crystal)
PREFIX ?= /usr/local

install:
	$(CRYSTAL_BIN) build --release -o bin/icr icr/cli.cr $(CRFLAGS)
	mkdir -p $(PREFIX)/bin
	cp ./bin/icr $(PREFIX)/bin
