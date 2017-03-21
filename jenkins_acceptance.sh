#!/bin/bash -e

SUITE=${1:-all}  # which test-kitchen suite to run, all by default
KEEP=${KEEP:-0}  # set to 1 to keep the Conjur EC2 instance running

readonly CONJUR_AMI='ami-e9d97eff'  # Conjur 4.9.0.1
readonly TEST_CONTAINER_TAG='conjur-cookbook-acceptance-test'
readonly CONCURRENCY=10  # number of test-kitchen suites to run in parallel

function finish() {
  if [ $KEEP -eq 0 ]; then
    testC kitchen destroy -c $CONCURRENCY $SUITE
  fi
}
trap finish EXIT

function main() {
  build_test_image
  run_kitchen_tests
}

function build_test_image() {
  echo 'Building test Docker image'
  docker build -f Dockerfile.kitchen -t $TEST_CONTAINER_TAG .
}

function testC() {
  # Run a command inside the test container
  summon -f secrets.ci.yml \
    docker run --rm \
      --env-file @SUMMONENVFILE \
      -e "AWS_PRIVATE_KEY=$(conjur variable value aws/ci/test-kitchen/private-key)" \
      -v $PWD:/src -w /src \
      $TEST_CONTAINER_TAG "$@"
}


function run_kitchen_tests() {
  testC kitchen test -c $CONCURRENCY $SUITE
}

main
