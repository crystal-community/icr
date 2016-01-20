CRYSTAL_BIN ?= $(shell which crystal)

build:
	$(CRYSTAL_BIN) build --release -o bin/icr src/icr/cli.cr $(CRFLAGS)
clean:
	rm -f ./bin/icr
test:
	$(CRYSTAL_BIN) spec
