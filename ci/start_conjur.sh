#!/bin/bash -e

# Save stdout to fd 4, then redirect stdout to stderr. The caller of
# this script expects to get results on stdout. Doing this redirection
# ensures that we can still what's going on with the commands we're
# running.
exec 4>&1 1>&2

build_host=$1; shift
build_user=$1; shift
build_api_key=$1; shift

cd $(dirname $0)

vagrant up
vagrant rsync

vagrant ssh -- sudo /vagrant/remote/conjurize.sh $build_host $build_user $build_api_key

start_info=$(vagrant ssh -- sudo /vagrant/remote/start_conjur.sh)

echo -n "$start_info" >&4
