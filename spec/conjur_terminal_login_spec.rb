require 'spec_helper'
require 'chef'
require "#{File.dirname(File.dirname(__FILE__))}/libraries/conjur_terminal_login"

describe ConjurTerminalLogin do
  subject {
    Struct.new(:dummy) do
      include ConjurTerminalLogin
    end.new
  }
  describe "#cacertfile" do
    it "obtains from /etc/conjur.conf" do
      subject.stub(:conjur_account).and_return "demo"
      subject.stub(:conjur_conf_filename).and_return "/etc/conjur.conf"
      subject.stub(:conjur_conf).and_return({ 'cert_file' => 'conjur.pem' })
      expect(File).to receive(:file?).with('/etc/conjur.pem').and_return(true)
      expect(File).to receive(:file?).with(File.expand_path('~/conjur-demo.pem')).and_return(true)
      expect(subject.conjur_cacertfile).to eq("/etc/conjur.pem")
    end
  end
  describe "host identity" do
    context "from netrc" do
      before {
        require 'ostruct'
        
        File.stub(:stat).and_call_original
        File.stub(:read).and_call_original
        File.stub(:stat).with("/root/.netrc").and_return OpenStruct.new(mode: 0600)
        File.stub(:read).with("/root/.netrc").and_return <<NETRC
machine https://conjur.example.com/api/authn
  login host/the-host
  password the-password
NETRC
        File.stub(:read).with("/etc/conjur.conf").and_return <<CONJUR_CONF
appliance_url: https://conjur.example.com/api
CONJUR_CONF
      }
    end
  end
end