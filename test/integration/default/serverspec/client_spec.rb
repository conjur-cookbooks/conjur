require 'spec_helper'

# describe command seems to be broken on some systems
# (stdout is returned as an empty string), so disable for now
# TODO: figure out why
SERVERSPEC_STDOUT_BROKEN = true

describe command('conjur help') do
  its(:stdout) { should match(/conjur \[global options\] command/) }
end unless SERVERSPEC_STDOUT_BROKEN
