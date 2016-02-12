#!/bin/bash -ex

cd $(dirname $0)

kitchen_instance=$1; shift
token=$1; shift
hostid=$1; shift
 
vagrant ssh -- sudo /vagrant/remote/create_host.sh $kitchen_instance $token $hostid
