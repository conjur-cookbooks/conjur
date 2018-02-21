require 'spec_helper'

describe "conjur::install" do
  let(:chef_run) {
    ChefSpec::SoloRunner.new(platform: platform, version: version) 
  }
  let(:subject) {
    chef_run.converge(described_recipe)
  }
  before {
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with('/etc/ssh/sshd_config').and_return("")
  }
  
  shared_examples_for "common installation" do
    { conjurers: 50000, users: 5000 }.each do |g, gid|
      it "creates group '#{g}'" do
        expect(subject).to create_group(g.to_s).with(gid: gid)
      end
    end
    %w(logshipper authkeylookup).each do |u|
      it "creates user'#{u}'" do
        expect(subject).to create_user(u)
      end
    end
    
    it "performs common install steps" do
      expect(subject).to run_ruby_block("Configure sshd with AuthorizedKeysCommand")
      expect(subject).to run_ruby_block("Tell sshd not to print the last login")
      expect(subject).to run_bash("mkfifo /var/run/logshipper")
    end
  end
  
  context "on ubuntu platform" do
    let(:platform) { 'ubuntu' }
    let(:version) { '12.04' }
    before {
      chef_run.node.automatic['platform_family'] = 'debian'
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

    context "version 16.04" do
      let(:version) { '16.04' }
      it "creates logshipper pipe with syslog group" do
        expect(subject).to render_file('/etc/systemd/system/logshipper.service')
          .with_content /chown logshipper:syslog/
      end
    end
  end

  context "centos platform" do
    let(:platform) { 'centos' }
    let(:version) { '6.2' }

    before {
      chef_run.node.automatic['platform_family'] = 'rhel'
      chef_run.node.automatic['conjur']['selinux_enabled'] = true
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
