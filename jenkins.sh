#!/bin/bash -e

readonly CONJUR_VERSION='4.9.0.1'  # these 2 vars are tied together, for now
readonly CONJUR_AMI='ami-e9d97eff'
readonly TEST_CONTAINER_TAG='conjur-cookbook-test'

KEEP=${KEEP:-0}  # set to 1 to keep the Conjur EC2 instance running

function finish() {
  if [ $KEEP -eq 0 ]; then
    destroy_conjur_instance
  fi
}
trap finish EXIT

function main() {
  build_test_image
  check_syntax
  lint_cookbook
  run_specs
}

function build_test_image() {
  echo 'Building test Docker image'
  docker build -f Dockerfile.unit -t $TEST_CONTAINER_TAG .
}

function testC() {
  # Run a command inside the test container
  docker run --rm -i \
    -v $PWD:/src -w /src \
    $TEST_CONTAINER_TAG "$@"
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

function create_conjur_instance() {
  echo 'Starting Conjur EC2 instance'
}

function destroy_conjur_instance() {
  echo 'Destroying Conjur EC2 instance'
}

main
