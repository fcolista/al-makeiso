.PHONY: build run test clean help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

VERSION:=$(shell cat ./version)
ISO:=$(shell ls ./iso/*.iso 2>/dev/null)
MAJORVER:=$(shell cat ./version | grep -Eo '^[0-9]{1}.[0-9]{2}')

build: ## Build the container
	$(info $$MAJORVER is [${MAJORVER}])
	@cat create-iso.in | sed -e "s/%MAJORVER%/$(MAJORVER)/g" -e "s/%FULLVER%/$(VERSION)/g">create-iso
	@docker build . --build-arg="VERSION=$(VERSION)" -t alpine-mkiso:$(VERSION)

run: ## Run container
	@mkdir -p iso
	@docker container run -it --rm --mount type=bind,source=./iso,target=/iso --name="alpineiso" alpine-mkiso:$(VERSION)

ISO := $(wildcard ./iso/*.iso)

test: ## Test ISO with QEMU
	@sh ./test-iso
	@sha256sum -b $(ISO) >$(ISO).sha256

clean: ## Clean all the generated files
	@rm -f create-iso
	@rm -f nohup.*
	@rm -f qemu.log
	@-rm -rf ./iso
ifeq ($(shell docker images -q alpine-mkiso:$(VERSION) 2> /dev/null),)
	@docker image rm -f alpine-mkiso:$(VERSION)
endif
