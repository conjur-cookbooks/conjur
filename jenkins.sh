#!/bin/bash -ex

bundle install

summon -f secrets.ci.yml bundle exec ci/test.rb
