#!/bin/bash -ex

img=registry.tld/conjur-appliance-cuke-master:4.6-stable
kitchen_name=$1; shift          # unused, eases debugging
conjur_cid=$1; shift
token=$1; shift
hostid=$1; shift

docker exec -i conjur conjur hostfactory host create $token $hostid | jsonfield api_key
