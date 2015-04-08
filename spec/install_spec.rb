require 'spec_helper'

describe "conjur::install" do
  let(:chef_run) {
    ChefSpec::SoloRunner.new(platform: platform, version: version) 
  }
  let(:subject) {
    chef_run.converge(described_recipe)
  }
  before {
    File.stub(:read).and_call_original
    File.stub(:read).with('/etc/ssh/sshd_config').and_return ""
  }
  
  shared_examples_for "common installation" do
    it "performs common install steps" do
      expect(subject).to run_ruby_block("Configure sshd with AuthorizedKeysCommand")
      expect(subject).to run_ruby_block("Tell sshd not to print the last login")
      expect(subject).to execute_bash("mkfifo /var/run/logshipper")
    end
  end
  
  context "ubuntu platform" do
    let(:platform) { 'ubuntu' }
    let(:version) { '12.04' }
    before {
      chef_run.node.automatic.platform_family = 'debian'
    }
    
    it_behaves_like "common installation"
    
    it "executes successfully" do
      expect(subject).to be_truthy
    end
    it "executes ubuntu scripts" do
      expect(subject).to run_execute("pam-auth-update")
      expect(subject).to add_apt_repository("conjur")
      expect(subject).to install_package("logshipper")
    end
  end
  context "centos platform" do
    let(:platform) { 'centos' }
    let(:version) { '6.2' }
    before {
      chef_run.node.automatic.platform_family = 'rhel'
    }
    
    it_behaves_like "common installation"
    
    it "executes successfully" do
      expect(subject).to be_truthy
    end
    it "executes centos scripts" do
      expect(subject).to run_execute("authconfig")
      expect(subject).to create_yum_repository("conjur")
      expect(subject).to install_package("logshipper")
      expect(subject).to create_cookbook_file("/tmp/logshipper.te")
    end
  end
end
