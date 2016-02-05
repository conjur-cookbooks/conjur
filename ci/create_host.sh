#!/bin/bash -ex

cd $(dirname $0)

host_type=$1; shift             # unused, just for debugging
token=$1; shift
hostid=$1; shift
 
vagrant ssh -- sudo /vagrant/_create_host.sh $token $hostid
