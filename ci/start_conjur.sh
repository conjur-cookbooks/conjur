#!/bin/bash -ex

cd $(dirname $0)

hostid="cookbook-ci/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

# Need to conjurize with conjurops so we can pull the image to run a
# local appliance.
conjur host show $hostid >/dev/null || ./conjurize.sh conjur-master.itp.conjur.net conjurops 3726wdk1ajtx9r365p6r815pgxjz1m2v78s1k21rht2k7ec1d2005x6e $hostid 1>&2

docker pull registry.tld/conjur-appliance-cuke-master:4.6-stable 1>&2

echo -n "$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
