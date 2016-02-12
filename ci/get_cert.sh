#!/bin/bash -ex

conjur_addr=$1; shift

openssl s_client -connect $conjur_addr:443 -showcerts </dev/null | awk '/BEGIN CERT/,/END CERT/ {print}' ORS='\\n'
