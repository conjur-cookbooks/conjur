require 'spec_helper'

describe "conjur::configure" do
  let(:chef_run) {
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04') do |node|
      attributes.each do |k,v|
        node.override[k] = v
      end
    end
  }
  let(:subject) {
    chef_run.converge(described_recipe)
  }
  let(:host_id) { "host/the-host" }
  let(:api_key) { "the-api-key" }
  let(:conjur_account) { "demo" }
  let(:conjur_appliance_url) { "https://conjur/api" }
  before {
    allow_any_instance_of(Chef::Resource).to receive(:conjur_host_id).and_return(host_id)
    allow_any_instance_of(Chef::Resource).to receive(:conjur_host_api_key).and_return(api_key)
    allow_any_instance_of(Chef::Resource).to receive(:conjur_account).and_return(conjur_account)
    allow_any_instance_of(Chef::Resource).to receive(:conjur_appliance_url).and_return(conjur_appliance_url)
    allow_any_instance_of(Chef::Resource).to receive(:conjur_cacertfile).and_return("/etc/conjur-demo.pem")
  }

  let(:attributes) { {} }
    
  it "creates /etc/ldap/ldap.conf" do
    expect(subject).to create_template("/etc/ldap/ldap.conf").with(
      variables: {
        account: conjur_account,
        host_id: host_id, 
        uri: "ldaps://conjur", 
        cacertfile: "/etc/conjur-demo.pem"
      }
    )
  end
  it "creates /etc/nslcd.conf" do
    expect(subject).to create_template("/etc/nslcd.conf").with(
      variables: {
        account: conjur_account,
        host_id: host_id, 
        host_api_key: api_key,
        gid: "nslcd",
        uri: "ldaps://conjur", 
        cacertfile: "/etc/conjur-demo.pem"
      }
    )
  end
  it "creates conjur_authorized_keys" do
    expect(subject).to create_template("/opt/conjur/bin/conjur_authorized_keys") { |params|
      expect(params[:variables]).to eq({
        uri: "https://conjur/api/pubkeys",
        options: including("--cacert /etc/conjur-demo.pem")
      })
    }
  end
end
