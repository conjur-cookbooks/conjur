#!/bin/bash -ex

buildno=${BUILD_NUMBER:-1}

docker build -t ci-conjur-cookbook:${buildno} .
docker run -i --rm \
  -v $PWD/ci/output:/src/output \
  ci-conjur-cookbook:${buildno} \
  bash -c 'berks package /cookbooks/conjur.tar.gz && mv /cookbooks/conjur.tar.gz /src/output/conjur.tar.gz'

if [ ! -z "$CONJUR_DOCKER_REGISTRY" ]; then
  img=$(./image_name.sh)
  docker tag ci-conjur-cookbook:${buildno} $img
  docker push $img
fi
