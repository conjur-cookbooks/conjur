require 'spec_helper'
describe command('conjur audit all -s') do
  its(:stdout) { should match(/ssh:login/) }
  its(:exit_status) { should eq 0 }
end
