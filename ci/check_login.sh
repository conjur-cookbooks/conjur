#!/bin/bash -ex

cd $(dirname $0)

vagrant ssh -- sudo /vagrant/_check_login.sh "$@"
