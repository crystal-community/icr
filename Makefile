CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN ?= $(shell which shards)
ICR_BIN ?= $(shell which icr)
PREFIX ?= /usr/local

build:
	$(SHARDS_BIN) --production build $(CRFLAGS)
clean:
	rm -f ./bin/icr ./bin/icr.dwarf
test: build
	$(CRYSTAL_BIN) spec
install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/icr $(PREFIX)/bin
reinstall: build
	cp ./bin/icr $(ICR_BIN) -rf
