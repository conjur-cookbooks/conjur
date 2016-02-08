#!/bin/bash -ex

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

addr=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
port=$(docker inspect conjur | jsonfield 0.NetworkSettings.Ports.443/tcp.0.HostPort)
cert="$(docker exec -i conjur cat /opt/conjur/etc/ssl/conjur.pem | awk '$1=$1' ORS='\\n')"

echo -n "$addr:443:$hf_token:$cert" >&4
