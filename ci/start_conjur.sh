#!/bin/bash -ex

run_conjurize() {
conjur hostfactory host create 3726wdk1ajtx9r365p6r815pgxjz1m2v78s1k21rht2k7ec1d2005x6e $hostid | \
  conjurize --ssh --sudo | vagrant ssh 1>&2
}

cd $(dirname $0)

vagrant up 1>&2
vagrant rsync 1>&2

hostid="cookbook-ci/$(vagrant ssh -- curl -s http://169.254.169.254/latest/meta-data/instance-id)"

conjur host show $hostid 1>&2 || run_conjurize

vagrant ssh -- sudo service nginx restart 1>&2

start_info=$(vagrant ssh -- sudo /vagrant/_start.sh)

echo -n "$hostid:$start_info"
