#!/bin/bash -ex

conjur_cid=$1;shift
host=$1;shift

docker exec -i $conjur_cid conjur audit resource -s host:$host | grep ssh:login
