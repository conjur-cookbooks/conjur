.PHONY: rubocop foodcritic rspec kitchen acceptance spinach

rubocop:
	chef exec rubocop --require rubocop/formatter/checkstyle_formatter --format RuboCop::Formatter::CheckstyleFormatter --no-color --out rubocop.xml

foodcritic:
	chef exec foodcritic .

rspec:
	chef exec rspec spec/

kitchen:
	conjur env run -- chef exec kitchen test -d always -c 3

acceptance: spinach spec

docker/cookbooks.tar.gz: Berksfile $(COOKBOOK_DIRS)
	chef exec berks package $@

spinach: $(addprefix features/reports/, $(PLATFORMS))

features/reports/%: docker/%.image $(COOKBOOK_DIRS)
	rm -rf $@
	mkdir -p $@
	CI_REPORTS=$@ TRUSTED_IMAGE=$(shell cat $<) spinach -r double_reporter

.SECONDEXPANSION:
docker/%.image: $(addprefix docker/, cookbooks.tar.gz conjur.conf Dockerfile $$*.docker)
	$(MAKE) -C docker $*.image
