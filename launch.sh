#!/bin/bash -e

key_file=/tmp/aws_private_key.pem

# Have docker allocate a pty if we're running interactively
[[ -t 0 ]] && t="-t"

docker run --rm -i $t \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SSH_KEY_ID \
  -e AWS_PRIVATE_KEY=$key_file \
  -v $AWS_PRIVATE_KEY:$key_file \
  -v $PWD/ci:/src/ci \
  -v $PWD/spec:/src/spec \
  -v $PWD/test:/src/test \
  -v $PWD/.kitchen:/src/.kitchen \
  -v $PWD/.kitchen.yml:/src/.kitchen.yml \
  ci-conjur-cookbook "$@"

