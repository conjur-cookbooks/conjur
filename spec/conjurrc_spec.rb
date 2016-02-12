require "spec_helper"

describe "conjur::conjurrc" do
  let :chef_run do
    ChefSpec::SoloRunner.new do |node|
      node.override['conjur']['configuration']['account'] = 'demo'
      node.override['conjur']['configuration']['appliance_url'] = 'https://conjur/api'
      node.override['conjur']['configuration']['ssl_certificate'] = 'the-cert'
    end.converge described_recipe
  end
  subject { chef_run }
    
  it "creates /etc/conjur.conf" do
    expect(subject).to create_file("/etc/conjur.conf").with(content: """
account: demo
appliance_url: https://conjur/api
plugins: []
netrc_path: /etc/conjur.identity
cert_file: /etc/conjur-demo.pem
"""
    )
  end
  it "creates /etc/conjur.pem" do
    expect(subject).to create_file("/etc/conjur-demo.pem").with(content: "the-cert")
  end
end
