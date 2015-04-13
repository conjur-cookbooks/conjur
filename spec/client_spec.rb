require "spec_helper"

describe "conjur::client" do
  let :chef_run do
    ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
      node.set["platform_family"] = platform_family if platform_family
      node.set["conjur"]['client']["version"] = "4.5.1-0"
    end.converge described_recipe
  end
  let(:chef_cache) { Chef::Config[:file_cache_path] }
  subject { chef_run }

  context "ubuntu" do
    let(:platform) { "ubuntu" }
    let(:version) { "12.04" }
    let(:platform_family) { nil }
    it "installs conjur apt package" do
      expect(subject).to create_remote_file("#{chef_cache}/conjur-4.5.1-0.deb")
      expect(subject).to install_dpkg_package("conjur").with(source: "#{chef_cache}/conjur-4.5.1-0.deb")
    end
  end
  context "fedora" do
    let(:platform) { "centos" }
    let(:platform_family) { "rhel" }
    let(:version) { "6.2" }
    it "installs conjur rpm package" do
      expect(subject).to create_remote_file("#{chef_cache}/conjur-4.5.1-0.rpm")
      expect(subject).to install_rpm_package("conjur").with(source: "#{chef_cache}/conjur-4.5.1-0.rpm")
    end
  end
end
