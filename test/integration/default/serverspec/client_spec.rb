require 'spec_helper'

describe command('conjur help') do
  its(:stdout) { should match(/conjur \[global options\] command/) }
end
