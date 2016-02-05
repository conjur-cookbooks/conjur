#!/bin/bash -ex

img=registry.tld/conjur-appliance-cuke-master:4.6-stable
token=$1
hostid=$2

docker exec -i conjur conjur hostfactory host create $token $hostid | jsonfield api_key
