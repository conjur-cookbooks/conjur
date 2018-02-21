#!/bin/bash -e

function main() {
  build_test_image
  check_syntax
  lint_cookbook
  run_specs
  test_kitchen
}

function build_test_image() {
  echo 'Building test Docker image'
  docker build -f Dockerfile.unit -t $TEST_IMAGE .
}

function testC() {
  # Run a command inside the test container
  docker run --rm -i -v $PWD:/src -w /src $TEST_IMAGE "$@"
}

function check_syntax() {
  echo 'Checking syntax with Rubocop'
  testC bash -s <<EOF
umask 000 # so it can be cleaned up without sudo
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
  testC foodcritic --progress . || :
}

function run_specs() {
  echo 'Running rspec unit tests'
  testC bash -s <<EOF
umask 000 # so it can be cleaned up without sudo
berks vendor vendor/
rspec --format documentation --format RspecJunitFormatter --out ci/reports/specs.xml spec/
EOF
}

function export_suites() {
  local suites=$(testC ruby -ryaml -e "puts YAML.load(File.read('.kitchen.yml'))['platforms'].collect {|p| %Q(default-#{p['name']})}.join(' ')")
  echo "SUITES=$suites" > env.properties
}

function test_kitchen() {
  ./kitchen.sh kitchen test -c -d always
}

# allow running manually or through Jenkins pipeline
TEST_IMAGE=${TEST_IMAGE:-conjur-cookbook-test}
COMMAND=${1:-main}
$COMMAND
