#!/bin/bash -ex

# Save stdout to fd 4, then redirect stdout to stderr. The caller of
# this script expects to get results on stdout. Doing this redirection
# ensures that we can still what's going on with the commands we're
# running.
exec 4>&1 1>&2

img=registry.tld/conjur-appliance-cuke-master:4.6-stable

docker rm -f conjur || true

docker pull $img

docker run -p 443:443 -p 636:636 -d --name conjur \
  -e CONJUR_APPLIANCE_URL=https://localhost/api \
  -e CONJUR_AUTHN_LOGIN=admin \
  -e CONJUR_AUTHN_API_KEY=secret \
  -e CONJUR_CERT_FILE=/opt/conjur/etc/ssl/conjur.pem \
  $img

docker run --rm --link conjur $img /opt/conjur/evoke/bin/wait_for_conjur

# gnutls_handshake on ubuntu12 fails if the DH prime is too
# short. Generate a longer one to make it happy.
docker exec -i conjur bash -c "openssl dhparam -out /etc/ssl/dhparam.pem 1024 && sv restart nginx"
docker run --rm --link conjur $img /opt/conjur/evoke/bin/wait_for_conjur


docker exec -i conjur \
  bash -c 'conjur layer create test_hosts && conjur hostfactory create --as-role user:admin --layer test_hosts hf'

hf_token=$(docker exec -i conjur \
  bash -c 'conjur hostfactory token create --duration-hours 1 hf' | jsonfield 0.token)

external_ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
internal_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

echo -n "$external_ip:$internal_ip:$hf_token" >&4
