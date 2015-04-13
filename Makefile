.PHONY: test spinach spec

COOKBOOK_DIRS = attributes files libraries recipes templates
PLATFORMS = phusion

test: spinach spec

spec:
	bundle exec rspec

docker/cookbooks.tar.gz: Berksfile $(COOKBOOK_DIRS)
	berks package $@

spinach: $(addprefix features/reports/, $(PLATFORMS))

features/reports/%: docker/%.image $(COOKBOOK_DIRS)
	rm -rf $@
	mkdir -p $@
	CI_REPORTS=$@ TRUSTED_IMAGE=$(shell cat $<) spinach -r double_reporter

.SECONDEXPANSION:
docker/%.image: $(addprefix docker/, cookbooks.tar.gz conjur.conf Dockerfile $$*.docker)
	$(MAKE) -C docker $*.image
