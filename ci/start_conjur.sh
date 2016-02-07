#!/bin/bash -ex

img=registry.tld/conjur-appliance-cuke-master:4.6-stable

docker rm -f conjur 1>&2 || true

docker pull $img 1>&2

conjur_cid=$(docker run  -P -d \
  -e CONJUR_APPLIANCE_URL=https://localhost/api \
  -e CONJUR_AUTHN_LOGIN=admin \
  -e CONJUR_AUTHN_API_KEY=secret \
  -e CONJUR_CERT_FILE=/opt/conjur/etc/ssl/conjur.pem \
  $img 1>&2)
docker run --rm --link $conjur_cid:conjur $img /opt/conjur/evoke/bin/wait_for_conjur 1>&2

# gnutls_handshake on ubuntu12 fails if the DH prime is too
# short. Generate a longer one to make it happy.
docker exec -i $conjur_cid bash -c "openssl dhparam -out /etc/ssl/dhparam.pem 1024 && sv restart nginx" 1>&2
docker run --rm --link $conjur_cid:conjur $img /opt/conjur/evoke/bin/wait_for_conjur 1>&2


docker exec -i $conjur_cid \
  bash -c 'conjur layer create test_hosts && conjur hostfactory create --as-role user:admin --layer test_hosts hf' 1>&2

hf_token=$(docker exec -i $conjur_cid \
  bash -c 'conjur hostfactory token create --duration-hours 1 hf' | jsonfield 0.token)

addr=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
port=$(docker inspect $conjur_cid 0.NetworkSettings.Ports.443/tcp.0.HostPort)
cert="$(docker exec -i $conjur_cid cat /opt/conjur/etc/ssl/conjur.pem | awk '$1=$1' ORS='\\n')"

echo -n "$conjur_cid:$addr:$port:$hf_token:$cert"
