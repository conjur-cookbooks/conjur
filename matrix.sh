#!/bin/bash -e

# If the tag has a slash in it, it's from a remote repo
if [ "$MATRIX_IMAGE_TAG" != "${MATRIX_IMAGE_TAG#*/}" ]; then
  docker pull $MATRIX_IMAGE_TAG
fi

./launch.sh ci/test.rb --conjur-external $CONJUR_EXTERNAL_ADDR --conjur-internal $CONJUR_INTERNAL_ADDR --conjur-token $CONJUR_TOKEN "$@"
