#!/bin/bash -e

build_host=$1; shift
build_user=$1; shift
build_api_key=$1; shift

cat - >/etc/conjur.conf <<'EOF'
---
account: conjurops
plugins: []
appliance_url: https://$build_host/api
cert_file: /etc/conjur-conjurops.pem
netrc_path: /etc/conjur.identity
EOF

cat - >/etc/conjur.identity <<EOF
machine https://$build_host/api/authn
  login $build_user
  password $build_api_key
EOF

openssl s_client -connect ${build_host}:443 -showcerts </dev/null | awk '/BEGIN CERT/,/END CERT/ {print}' > /etc/conjur-conjurops.pem

service nginx restart
