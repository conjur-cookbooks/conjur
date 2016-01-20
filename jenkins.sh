#!/bin/bash -ex

bundle install --path vendor/bundle

bundle exec make rubocop || true

# chef exec make -j spinach # fails undeterministically

chef exec make -j rspec

chef exec make -j foodcritic kitchen
