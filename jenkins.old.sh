#!/bin/bash -ex

# Parse .kitchen.yml, grab the names of all the instances
instances=$(ruby -ryaml -e "puts YAML.load(File.read('.kitchen.yml'))['platforms'].collect {|p| %Q(default-#{p['name']})}.join(' ')")
echo "SUITES=$instances" > env.properties

./setup.sh >> env.properties
