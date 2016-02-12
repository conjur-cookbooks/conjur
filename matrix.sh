#!/bin/bash -e

if [ ! -z "$MATRIX_IMAGE_TAG" ]; then
  docker pull $MATRIX_IMAGE_TAG
fi

./launch.sh bundle exec ci/test.rb --conjur-external $CONJUR_EXTERNAL_ADDR --conjur-internal $CONJUR_INTERNAL_ADDR --conjur-token $CONJUR_TOKEN "$@"
