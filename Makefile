.PHONY: kitchen acceptance spinach

COOKBOOK_DIRS = attributes files libraries recipes templates
PLATFORMS = trusty phusion
CHEF_EXEC=$(if $(shell which chef > /dev/null 2>&1),chef exec,)

acceptance: spinach

kitchen:
	conjur env run -- $(CHEF_EXEC) kitchen test -d always -c 3

docker/cookbooks.tar.gz: Berksfile $(COOKBOOK_DIRS)
	$(CHEF_EXEC) berks package $@

spinach: $(addprefix features/reports/, $(PLATFORMS))

features/reports/%: docker/%.image $(COOKBOOK_DIRS) features
	rm -rf $@
	mkdir -p $@
	# CI_REPORTS=$@ TRUSTED_IMAGE=$(shell cat $<) spinach -r double_reporter

.SECONDARY: phusion.image trusty.image
.SECONDEXPANSION:
docker/%.image: $(addprefix docker/, cookbooks.tar.gz conjur.conf Dockerfile $$*.docker)
	$(MAKE) -C docker $*.image
