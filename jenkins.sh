#!/bin/bash -ex

./build.sh

summon -f secrets.ci.yml ./test.sh
