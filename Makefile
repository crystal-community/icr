CRYSTAL_BIN ?= $(shell which crystal)
ICR_BIN ?= $(shell which icr)

build:
	$(CRYSTAL_BIN) build --release -o bin/icr src/icr/cli.cr $(CRFLAGS)
clean:
	rm -f ./bin/icr
test:
	$(CRYSTAL_BIN) spec
reinstall:
	cp ./bin/icr $(ICR_BIN) -rf
