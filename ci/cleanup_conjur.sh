#!/bin/bash -ex

hostid=$1; shift
cd $(dirname $0)

vagrant destroy -f
conjur host retire $hostid
