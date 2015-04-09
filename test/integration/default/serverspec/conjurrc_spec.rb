require 'serverspec'

describe file('/etc/conjur.conf') do
  it { should be_mode(644) }
  its(:content) { should contain "account: demo" }
  its(:content) { should contain "cert_file: /etc/conjur-demo.pem" }
end

describe file('/etc/conjur-demo.pem') do
  it { should be_mode(644) }
  its(:content) { should contain "BEGIN CERTIFICATE" }
end
