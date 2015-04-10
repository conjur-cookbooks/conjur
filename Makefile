.PHONY: vendor test

COOKBOOK_DIRS = attributes files libraries recipes templates

vendor:
	berks vendor .vendor

test: vendor
	bundle exec rspec

docker/cookbooks.tar.gz: Berksfile Berksfile.lock $(COOKBOOK_DIRS)
	berks package $@

.SECONDEXPANSION:
docker/%.image: $(addprefix docker/, cookbooks.tar.gz conjur.conf Dockerfile $$*.docker)
	$(MAKE) -C docker $*.image
