#!/bin/bash -ex

exec 4>&1 1>&2

./build.sh

conjur_info=( $(./start_conjur.sh) )

cat - >&4 <<EOF
CONJUR_EXTERNAL_ADDR=${conjur_info[0]}
CONJUR_INTERNAL_ADDR=${conjur_info[1]}
CONJUR_TOKEN=${conjur_info[2]}
MATRIX_IMAGE_TAG=$(./image_name.sh)
EOF
