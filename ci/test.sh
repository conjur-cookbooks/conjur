#!/bin/bash -ex

src_output=/src/output
ci_output="$PWD/ci/output"
output="$ci_output:$src_output"

cleanup() {
  kitchen destroy -c
  (cd ci; vagrant destroy -f)
  conjur host retire $conjur_hostid
}

finish() {
  echo "${start_info[*]}"
  # cleanup
}

trap finish EXIT

clean_output() {
    docker run --rm -v $output alpine /bin/sh -xc "rm -rf $src_output/*"
}

build_ci_containers() {
    docker build -t ci-conjur-cookbook -f docker/Dockerfile .

    # Take advantage of the docker layer cache to work around the fact
    # that berks package isn't idempotent.
    docker build -t ci-cookbook-storage -f docker/Dockerfile.cookbook .
    docker run -i --rm -v "$output" ci-cookbook-storage bash -c 'mkdir -p /src/output && mv /cookbooks/conjur.tar.gz /src/output/cookbooks.tar.gz'
}

lint_cookbook() {
    docker run -i --rm -v "$output" ci-conjur-cookbook chef exec rubocop --require rubocop/formatter/checkstyle_formatter --format RuboCop::Formatter::CheckstyleFormatter --no-color --out $src_output/rubocop.xml || true
    
    docker run -i --rm ci-conjur-cookbook chef exec foodcritic . || true
}

run_tests() {
  docker run -i --rm -v "$output" -v $PWD/spec:/src/spec ci-conjur-cookbook chef exec rspec --format RspecJunitFormatter --out /src/spec/report.xml spec/ || true

  start_info=( $(ci/start.sh) )
  echo "${start_info[*]}"
  conjur_hostid=${start_info[0]}
  echo "$conjur_hostid"
  conjur_addr=${start_info[1]}
  echo "$conjur_addr"
  token=${start_info[2]}
  echo "$token"

  chef exec kitchen converge -c 3

  # There doesn't currently appear to be an easy way to retrieve
  # results from test-kitchen. So, use the the return code here to
  # fail the build if the tests fail.
  chef exec kitchen verify

  for h in $(kitchen list -b); do
    chef exec kitchen exec $h -c "sudo /tmp/kitchen/data/conjurize.sh $conjur_addr $token"
    host=$(chef exec kitchen exec $h -c "sudo conjur authn whoami" | grep -v 'Execute command on' | jsonfield username | sed 's;host/;;')
    echo "$host"
    (ci/check_login.sh $host || echo "no ssh:login found for $host")  > ci/output/${h}-login.log
  done
}

clean_output
build_ci_containers
lint_cookbook
run_tests
