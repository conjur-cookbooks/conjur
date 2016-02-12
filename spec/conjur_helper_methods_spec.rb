require 'spec_helper'	
require 'chef'
require "#{File.dirname(File.dirname(__FILE__))}/libraries/conjur_helper_methods"

describe ConjurHelperMethods do
  subject {
    Struct.new(:dummy, :node) do
      include ConjurHelperMethods
    end.new
  }
  describe "#cacertfile" do
    it "obtains from /etc/conjur.conf" do
      allow(subject).to receive(:conjur_account).and_return("demo")
      allow(subject).to receive(:conjur_conf_filename).and_return("/etc/conjur.conf")
      allow(subject).to receive(:conjur_conf).and_return({ 'cert_file' => 'conjur.pem' })
      expect(File).to receive(:file?).with('/etc/conjur.pem').and_return(true)
      expect(File).to receive(:file?).with(File.expand_path('~/conjur-demo.pem')).and_return(true)
      expect(subject.conjur_cacertfile).to eq("/etc/conjur.pem")
    end
  end
  describe "host identity" do
    context "from environment" do
      let(:login) { "host/the-host" }
      let(:api_key) { "the-api-key" }
      before do
        allow(subject).to receive(:conjur_netrc).and_return([])
        allow(ENV).to receive(:[]).and_call_original
        expect(ENV).to receive(:[]).with("CONJUR_AUTHN_LOGIN").and_return(login)
        expect(ENV).to receive(:[]).with("CONJUR_AUTHN_API_KEY").and_return(api_key)
      end
      it "extracts the identity" do
        expect(subject.conjur_host_id).to eq("the-host")
        expect(subject.conjur_host_api_key).to eq(api_key)
      end
    end
    context "from netrc" do
      let(:login) { "host/the-host" }
      let(:api_key) { "the-api-key" }
      before do
        expect(subject).to receive(:conjur_netrc).at_least(1).and_return(netrc)
      end
      context "when found" do
        let(:netrc) { [ login, api_key ] }
        it "extracts the identity" do
          expect(subject.conjur_host_id).to eq("the-host")
          expect(subject.conjur_host_api_key).to eq(api_key)
        end
      end
      context "when not found" do
        let(:netrc) { [ ] }
        it "reports the error" do
          expect{ subject.conjur_host_id }.to raise_error(/^No host identity is available/)
        end
      end
    end
  end
end
