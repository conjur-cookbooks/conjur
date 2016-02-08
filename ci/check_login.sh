#!/bin/bash -ex

cd $(dirname $0)

vagrant ssh -- sudo /vagrant/remote/check_login.sh "$@"
