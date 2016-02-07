#!/bin/bash -ex

bundle install

summon -f secrets.ci.yml ci/test.rb
