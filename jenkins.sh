#!/bin/bash -e

readonly TEST_CONTAINER_TAG='conjur-cookbook-test'

function main() {
  build_test_image
  check_syntax
  lint_cookbook
  run_specs

  ./jenkins_acceptance.sh
}

function build_test_image() {
  echo 'Building test Docker image'
  docker build -f Dockerfile.unit -t $TEST_CONTAINER_TAG .
}

function testC() {
  # Run a command inside the test container
  docker run --rm -i -v $PWD:/src -w /src $TEST_CONTAINER_TAG "$@"
}

function check_syntax() {
  echo 'Checking syntax with Rubocop'
  testC bash -s <<EOF
rubocop --format progress \
  --require rubocop/formatter/checkstyle_formatter \
  --format RuboCop::Formatter::CheckstyleFormatter \
  --no-color --fail-level F \
  --out ci/reports/rubocop.xml \
  .
EOF
}

function lint_cookbook() {
  echo 'Linting cookbook with foodcritic'
  testC foodcritic --progress .
}

function run_specs() {
  echo 'Running rspec unit tests'
  testC rspec --format documentation --format RspecJunitFormatter --out ci/reports/specs.xml spec/
}

main
