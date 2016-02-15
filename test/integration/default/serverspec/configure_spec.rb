require 'spec_helper'
describe command('conjur audit all') do
  its(:stdout) { should match(/"action": "login"/) }
  its(:exit_status) { should eq 0 }
end
