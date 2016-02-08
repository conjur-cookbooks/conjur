#!/bin/bash -ex

kitchen_instance=$1; shift          # unused, eases debugging
token=$1; shift
hostid=$1; shift

docker exec -i conjur conjur hostfactory host create $token $hostid | jsonfield api_key
