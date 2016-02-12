#!/bin/bash -ex

docker build -t ci-conjur-cookbook .
      
# Take advantage of the docker layer cache to work around the fact
# that berks package isn't idempotent.
docker build -t ci-cookbook-storage -f docker/Dockerfile.cookbook .
docker run -i --rm -v $PWD/ci/output:/src/output ci-cookbook-storage mv /cookbooks/conjur.tar.gz /src/output/cookbooks.tar.gz
