require 'serverspec'

describe file('/etc/conjur.identity') do
  it { should be_grouped_into('conjur') }
  it { should be_mode(640) }
  its(:content) { should contain "machine https://conjur/api/authn" }
  its(:content) { should contain "login host/the-host" }
  its(:content) { should contain "password the-password" }
end
