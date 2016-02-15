#!/bin/bash -e

./launch.sh bundle exec ci/start_conjur.rb --conjur-creds "$(ci/conjur_creds.rb)"
