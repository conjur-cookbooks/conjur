#!/bin/bash -ex

host=$1;shift

docker exec -i conjur conjur audit resource -s host:$host | grep ssh:login
