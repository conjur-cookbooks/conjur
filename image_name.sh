#!/bin/bash -ex

if [ ! -z "$MATRIX_IMAGE_TAG" ] ; then
  echo $MATRIX_IMAGE_TAG
else
  registry=${CONJUR_DOCKER_REGISTRY+${CONJUR_DOCKER_REGISTRY}/}
  buildno=${BUILD_NUMBER+:${BUILD_NUMBER}}
  echo "${registry}ci-conjur-cookbook${buildno}"
fi
