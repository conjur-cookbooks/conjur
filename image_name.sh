#!/bin/bash

registry=${CONJUR_DOCKER_REGISTRY+${CONJUR_DOCKER_REGISTRY}/}
buildno=${BUILD_NUMBER+:${BUILD_NUMBER}}
echo "${registry}ci-conjur-cookbook${buildno}"
