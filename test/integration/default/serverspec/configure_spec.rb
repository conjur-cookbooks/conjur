require 'spec_helper'
describe command('conjur audit all -s') do
  pending('Hooking up a Conjur instance to test against') do
    its(:stdout) { should match(/ssh:login/) }
    its(:exit_status) { should eq 0 }
  end
end
