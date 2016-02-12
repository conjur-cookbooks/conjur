#!/bin/bash -ex

buildno=${BUILD_NUMBER+:${BUILD_NUMBER}}
docker build -t ci-conjur-cookbook${buildno} .
      
# Take advantage of the docker layer cache to work around the fact
# that berks package isn't idempotent.
docker build -t ci-cookbook-storage -f docker/Dockerfile.cookbook .
docker run -i --rm -v $PWD/ci/output:/src/output ci-cookbook-storage mv /cookbooks/conjur.tar.gz /src/output/cookbooks.tar.gz

if [ ! -z "$CONJUR_DOCKER_REGISTRY" ]; then
  img=$(./image_name.sh)
  docker tag ci-conjur-bookbook${buildno} $img
  docker push $img
fi
