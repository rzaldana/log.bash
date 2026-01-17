.PHONY: test

SHELL := /usr/bin/env bash

ROOT_DIR_WITH_SLASH := $(dir $(lastword $(MAKEFILE_LIST)))
ROOT_DIR := $(ROOT_DIR_WITH_SLASH:/=)

CURRENT_DIR_WITH_SLASH := $(dir $(firstword $(MAKEFILE_LIST)))
CURRENT_DIR := $(CURRENT_DIR_WITH_SLASH:/=)

IMAGE_TAGS_FILE := $(ROOT_DIR)/.image_tags

DOCKER_CONTEXT := $(ROOT_DIR)
DOCKERFILE := $(DOCKER_CONTEXT)/Dockerfile

SUPPORTED_VERSIONS_FILE := $(ROOT_DIR)/SUPPORTED_BASH_VERSIONS

SUBMODULES := $(wildcard $(CURRENT_DIR)/src/*/*.bash)

echo:
	@echo "$(SUBMODULES)"

# All .bash files in ./src 
SRC_BASH := $(wildcard $(CURRENT_DIR)/src/*.bash)

# Map them into ./
DST_BASH := $(patsubst $(CURRENT_DIR)/src/%.bash,$(CURRENT_DIR)/%.bash,$(SRC_BASH))


$(IMAGE_TAGS_FILE): $(ROOT_DIR)/Dockerfile $(ROOT_DIR)/SUPPORTED_BASH_VERSIONS
	@if [[ -f "$(IMAGE_TAGS_FILE)" ]]; then \
		echo "Deleting existing image tags file..."; \
		rm "$(IMAGE_TAGS_FILE)"; \
	else \
		echo "No image tags file present. Creating"; \
	fi
	@while IFS= read -r bash_version; do \
  	echo "========== building container image for bash version $$bash_version =========="; \
  	image_tag="blog_test_bash_$$bash_version"; \
  	docker build \
			--tag "$$image_tag" \
    	--build-arg "BASH_VERSION=$$bash_version" \
    	"$(DOCKER_CONTEXT)"; \
  	echo "$$image_tag" >> "$(IMAGE_TAGS_FILE)"; \
	done < "$(SUPPORTED_VERSIONS_FILE)"

build: $(DST_BASH)

#$(CURRENT_DIR)/%.bash: $(CURRENT_DIR)/src/%.bash $(SUBMODULES)
#	@$(ROOT_DIR)/submodules/blink/blink "$<" "$@"
#
$(DST_BASH): %.bash: src/%.bash $(SUBMODULES)
	@$(ROOT_DIR)/submodules/blink/blink "$<" "$@"

#%.bash: src/%.bash $(SUBMODULES) 
#	@$(ROOT_DIR)/submodules/blink/blink "$<" "$@"

#$(CURRENT_DIR)/src/%.bash: $(CURRENT_DIR)/src/%.bash 
#	@$(ROOT_DIR)/submodules/blink/blink "$<" "$@"


test: $(IMAGE_TAGS_FILE) $(DST_BASH)
	@while IFS= read -r image_tag; do \
		echo "========== running tests in image $$image_tag =========="; \
		docker run \
		--rm \
		--tty \
		--volume "$(CURRENT_DIR):/var/task" \
		--entrypoint bash_unit "$$image_tag" $(CURRENT_DIR)/test/test_*.bash; \
	done < "$(IMAGE_TAGS_FILE)"

