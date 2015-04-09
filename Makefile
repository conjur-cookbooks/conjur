.PHONY: vendor test

COOKBOOK_DIRS = attributes files libraries recipes templates

vendor:
	berks vendor .vendor

test: vendor
	bundle exec rspec

cookbooks.tar.gz: Berksfile Berksfile.lock $(COOKBOOK_DIRS)
	berks package $@

TAG = conjur-cookbook-test-$*

docker/%.image: docker/% cookbooks.tar.gz
	cp cookbooks.tar.gz $<
	docker build -t $(TAG) $<
	docker inspect -f '{{.Id}}' $(TAG) > $@
	rm $</cookbooks.tar.gz
