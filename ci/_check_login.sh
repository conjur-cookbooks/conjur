#!/bin/bash -ex

img=registry.tld/conjur-appliance-cuke-master:4.6-stable

host=$1

docker run --rm --link conjur \
  -e CONJUR_APPLIANCE_URL=https://conjur/api \
  -e CONJUR_AUTHN_LOGIN=admin \
  -e CONJUR_AUTHN_API_KEY=secret \
  -e CONJUR_CERT_FIELD=/opt/conjur/etc/ssl/conjur.pem \
  $img \
  bash -c "conjur audit resource -s host:$host" | grep ssh:login
