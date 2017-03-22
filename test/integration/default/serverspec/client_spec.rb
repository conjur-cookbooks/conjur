require 'spec_helper'

describe command('conjur help') do
  pending('This is pulling from the CLI package from an outdated place') do
    its(:stdout) { should match(/conjur \[global options\] command/) }
  end
end
