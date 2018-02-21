#!/bin/sh

TEST_IMAGE=${TEST_IMAGE:-conjur-cookbook-test}
if [ -z "$AWS_SSH_KEY" ]; then
  echo 'AWS_SSH_KEY variable not found. Did you mean to run with summon?'
  exit 1
fi

docker run --rm \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY \
  -v $AWS_SSH_KEY:/var/sshkey.pem:ro \
  -v $PWD:/src -w /src \
  $(tty -s && echo " -it") \
  $TEST_IMAGE "$@"

