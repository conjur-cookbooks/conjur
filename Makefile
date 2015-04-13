.PHONY: vendor test kitchen

vendor:
	berks vendor .vendor

test: vendor
	bundle exec rspec

kitchen:
	conjur env run -- chef exec kitchen test -d always -c 3
