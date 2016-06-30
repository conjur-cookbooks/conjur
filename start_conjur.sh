#!/bin/bash -e

./launch.sh chef exec ci/start_conjur.rb --conjur-creds "$(ci/conjur_creds.rb)"
