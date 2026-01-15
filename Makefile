.PHONY: test

.image_tags: ./test/Dockerfile
	@./scripts/build_test_containers

test: .image_tags
	@./scripts/test
