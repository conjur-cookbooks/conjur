#!/bin/bash -ex

exec 4>&1 1>&2

key_file=/tmp/aws_private_key.pem

img=$(./image_name.sh)
if [ ! -z "$CONJUR_DOCKER_REGISTRY" ]; then
  docker pull $img
fi

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
  $img "$@" >&4
