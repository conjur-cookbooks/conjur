#!/bin/bash -ex

docker build -t ci-conjur-cookbook -f ci/Dockerfile .

docker run -it --rm ci-conjur-cookbook bundle exec make rubocop || true

# chef exec make -j spinach # fails undeterministically

chef exec make rspec

chef exec make foodcritic

# chef exec make kitchen
