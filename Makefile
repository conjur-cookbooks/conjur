.PHONY: rubocop foodcritic rspec kitchen

rubocop:
	chef exec rubocop --require rubocop/formatter/checkstyle_formatter --format RuboCop::Formatter::CheckstyleFormatter --no-color --out rubocop.xml

foodcritic:
	chef exec foodcritic .

rspec:
	chef exec rspec spec/

kitchen:
	conjur env run -- chef exec kitchen test -d always -c 3
