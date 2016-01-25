#!/bin/bash -ex

src_output=/src/output
ci_output="$PWD/ci/output"
output="$ci_output:$src_output"

platforms="trusty phusion"

finish() {
  for p in $platforms; do
    docker rm -f conjur-cookbook-test-$p-$$
  done
  docker rm -f $conjur_cid
  rm -f $cert
}
# trap finish EXIT

clean_output() {
    docker run --rm -v $output alpine /bin/sh -xc "rm -rf $src_output/*"
}

build_ci_containers() {
    docker build -t ci-conjur-cookbook -f docker/Dockerfile .

    # Take advantage of the docker layer cache to work around the fact
    # that berks package isn't idempotent.
    docker build -t ci-cookbook-storage -f docker/Dockerfile.cookbook .
    docker run -i --rm ci-cookbook-storage bash -c 'rm -f /src/output/cookbooks.tar.gz && cat /cookbooks/conjur.tar.gz' > ci/output/cookbooks.tar.gz

    # docker run -i --rm -v $PWD/ci/output:/src/output ci-conjur-cookbook berks package /src/output/cookbooks.tar.gz
}

build_platforms() {
    for p in $platforms; do 
      img=conjur-cookbook-test-$p
      docker build -t $img  -f docker/$p.docker .
    done
}

lint_cookbook() {
    docker run -i --rm -v "$output" ci-conjur-cookbook chef exec rubocop --require rubocop/formatter/checkstyle_formatter --format RuboCop::Formatter::CheckstyleFormatter --no-color --out $src_output/rubocop.xml || true
    
    docker run -i --rm ci-conjur-cookbook chef exec foodcritic . || true
}

test_platforms() {
  conjur_image=registry.tld/conjur-appliance-cuke-master:4.6-stable
  docker pull $conjur_image

  conjur_cid=$(docker run -d $conjur_image)
  docker run --rm --link $conjur_cid:conjur $conjur_image /opt/conjur/evoke/bin/wait_for_conjur
  cert_file=conjur-cucumber.pem
  cert=$ci_output/$cert_file
  docker exec -i $conjur_cid cat /opt/conjur/etc/ssl/conjur.pem > $cert

  for p in $platforms; do
    host_json=$(docker run -i --rm --link $conjur_cid:conjur \
                  -v "$output" \
                  -e CONJUR_APPLIANCE_URL=https://conjur/api \
                  -e CONJUR_CERT_FILE=/src/output/$cert_file \
                  -e CONJUR_ACCOUNT=cucumber \
                  -e CONJUR_AUTHN_LOGIN=admin \
                  -e CONJUR_AUTHN_API_KEY=secret \
                  $conjur_image bash -c 'cd /opt/conjur/conjur-cli/current && bundle exec conjur host create')
    host_name=$(jsonfield id "$host_json")

    img=conjur-cookbook-test-$p
    name=${img}-$$
    docker run -d --name $name \
      --link $conjur_cid:conjur \
      -v "$output" \
      -e CONJUR_APPLIANCE_URL=https://conjur/api \
      -e CONJUR_CERT_FILE=/src/output/$cert_file \
      -e CONJUR_ACCOUNT=cucumber \
      -e CONJUR_AUTHN_LOGIN=host/$host_name \
      -e CONJUR_AUTHN_API_KEY=$(jsonfield api_key "$host_json") \
      $img

    for i in {1..10}; do
      docker run --rm --link $name:test-host alpine nc test-host 22 && break
      sleep 1
    done
    docker run --rm --link $name:test-host alpine nc test-host 22

    docker exec -i  $name chef-solo -o conjur::configure

    docker run -it --rm \
      --link $conjur_cid:conjur \
      --link $name:test-host \
      -v $PWD/features:/src/features \
      -v "$output" \
      -e TRUSTED_IMAGE=$img \
      -e CONJUR_APPLIANCE_URL=https://conjur/api \
      -e CONJUR_CERT_FILE=/src/output/$cert_file \
      -e CONJUR_ACCOUNT=cucumber \
      -e CONJUR_AUTHN_LOGIN=admin \
      -e CONJUR_AUTHN_API_KEY=secret \
      -e HOST_RESOURCE=$host_name \
      ci-conjur-cookbook chef exec spinach -r double_reporter || true
  done
  
}

run_tests() {
  # docker run -i --rm -v "$output" -v $PWD/spec:/src/spec ci-conjur-cookbook chef exec rspec --format RspecJunitFormatter --out $src_output/spec/report.xml spec/ || true

  test_platforms
  # conjur env run -- chef exec kitchen test -d always -c 3
}

clean_output
build_ci_containers
lint_cookbook
build_platforms
run_tests

