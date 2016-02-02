#!/bin/bash -ex

appliance_addr=$1
account=cucumber
token=$2
host="ec2/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

echo "$appliance_addr cuke-master" >> /etc/hosts
ssl_cert=$(openssl s_client -connect cuke-master:443 -showcerts </dev/null | awk '/BEGIN CERT/,/END CERT/ {print}' ORS='\\n')
cat - >/tmp/client.json <<EOF
{
  "conjur": {
    "configuration": {
      "account": "cucumber",
      "appliance_url": "https://cuke-master/api",
      "ssl_certificate": "$ssl_cert"
    }
  }
}
EOF

chef-solo -c /tmp/kitchen/client.rb -o conjur::conjurrc -j /tmp/client.json

export PATH=/usr/local/bin:$PATH

conjur plugin install host-factory 1>&2
new_host_json=$(conjur hostfactory host create $token $host)
api_key=$(jsonfield api_key "$new_host_json")

cat - >/tmp/identity.json <<EOF
{
  "conjur": {
    "identity": {
      "account": "cucumber",
      "login": "host/$host",
      "password": "$api_key"
    }
  }
}
EOF

chef-solo -c /tmp/kitchen/client.rb -o conjur::identity,conjur::configure -j /tmp/identity.json
