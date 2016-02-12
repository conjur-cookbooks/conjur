#!/bin/bash -e

./launch.sh bundle exec ci/test.rb --conjur-creds "$(ci/conjur_creds.rb)" "$@"
