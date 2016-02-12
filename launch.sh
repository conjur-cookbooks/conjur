#!/bin/bash -ex

exec 4>&1 1>&2

key_file=/tmp/aws_private_key.pem

docker run --rm -i \
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
  $(./image_name.sh) "$@" >&4
