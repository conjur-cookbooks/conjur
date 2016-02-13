#!/bin/bash -ex

# This script is meant to help a developer run the tests the same way
# jenkins run thems.

./jenkins.sh

env -S "$(cat env.properties | grep -v SUITES)" ./matrix.sh "$@"
