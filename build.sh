#!/bin/bash -ex

buildno=${BUILD_NUMBER+:${BUILD_NUMBER}}

docker pull ruby:2.1
docker build -t ci-conjur-cookbook${buildno} .

# Take advantage of the docker layer cache to work around the fact
# that berks package isn't idempotent.
docker build -t ci-cookbook-storage -f Dockerfile.cookbook .
docker run -i --rm -v $PWD/ci/output:/src/output ci-cookbook-storage mv /cookbooks/conjur.tar.gz /src/output/conjur.tar.gz

if [ ! -z "$CONJUR_DOCKER_REGISTRY" ]; then
  img=$(./image_name.sh)
  docker tag ci-conjur-cookbook${buildno} $img
  docker push $img
fi
