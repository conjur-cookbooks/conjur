#!/bin/bash -e

cd $(dirname $0)

cert=$(vagrant ssh -- sudo docker exec -i conjur cat /opt/conjur/etc/ssl/conjur.pem | awk '$1=$1' ORS='\\n')
cat - <<EOF
{
  "conjur": {
    "configuration": {
      "account": "cucumber",
      "appliance_url": "http://cuke-master/api",
      "ssl_certificate": "$cert"
    }
  }
}
EOF
