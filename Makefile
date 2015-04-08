.PHONY: vendor test

vendor:
	berks vendor .vendor

test: vendor
	bundle exec rspec
