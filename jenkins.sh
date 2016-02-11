#!/bin/bash -exu

./build.sh

summon -f secrets.ci.yml ./test.sh --only ${SUITE}
