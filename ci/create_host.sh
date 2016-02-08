#!/bin/bash -ex

kitchen_name=$1; shift          # unused, eases debugging
conjur_cid=$1; shift
token=$1; shift
hostid=$1; shift

docker exec -i $conjur_cid conjur hostfactory host create $token $hostid | jsonfield api_key
