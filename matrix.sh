#!/bin/bash -e

prop_file=$1; shift

external=$(awk -F '=' '/CONJUR_EXTERNAL_ADDR/ {print $2}' $prop_file)
internal=$(awk -F '=' '/CONJUR_INTERNAL_ADDR/ {print $2}' $prop_file)
token=$(awk -F '=' '/CONJUR_TOKEN/ {print $2}' $prop_file)

./launch.sh bundle exec ci/test.rb --conjur-external $external --conjur-internal $internal --conjur-token $token "$@"
