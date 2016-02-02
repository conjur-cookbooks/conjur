#!/bin/bash -ex

img=registry.tld/conjur-appliance-cuke-master:4.6-stable

docker rm -f conjur 1>&2 || true

docker pull $img 1>&2

docker run  -p 443:443 -p 636:636 -p 5432:5432 --name conjur -d $img 1>&2
docker run --rm --link conjur $img /opt/conjur/evoke/bin/wait_for_conjur 1>&2

docker run --rm --link conjur \
  -e CONJUR_APPLIANCE_URL=https://conjur/api \
  -e CONJUR_AUTHN_LOGIN=admin \
  -e CONJUR_AUTHN_API_KEY=secret \
  -e CONJUR_CERT_FILE=/opt/conjur/etc/ssl/conjur.pem \
  $img \
  bash -c 'conjur layer create test_hosts && conjur hostfactory create --as-role user:admin --layer test_hosts hf' 1>&2

hf_token=$(docker run --rm --link conjur \
  -e CONJUR_APPLIANCE_URL=https://conjur/api \
  -e CONJUR_AUTHN_LOGIN=admin \
  -e CONJUR_AUTHN_API_KEY=secret \
  -e CONJUR_CERT_FILE=/opt/conjur/etc/ssl/conjur.pem \
  $img \
  bash -c 'conjur hostfactory token create --duration-hours 1 hf' | jsonfield 0.token)

addr=$(curl -k http://169.254.169.254/latest/meta-data/public-ipv4)
echo -n "$addr $hf_token"
