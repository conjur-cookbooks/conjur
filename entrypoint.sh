#!/bin/bash -e

printenv AWS_PRIVATE_KEY > /tmp/key.pem
chmod 600 /tmp/key.pem

exec "$@"
