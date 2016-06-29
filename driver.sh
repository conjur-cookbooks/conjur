#!/bin/bash -ex

# This script is meant to help a developer run the tests the same way
# jenkins runs them.

./jenkins.sh

env -S "$(cat env.properties | grep -v SUITES)" ./matrix.sh "$@"
