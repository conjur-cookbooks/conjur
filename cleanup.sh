#!/bin/bash -x

./launch.sh ci/cleanup.sh
docker run -v /var/run/docker.sock:/var/run/docker.sock --rm registry.tld/docker-cleanup --older-than 10.days  --match ci-conjur-cookbook
