require 'spec_helper'

describe 'conjur::_users' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  { conjurers: 50000, users: 5000 }.each do |g, gid|
    it "creates group '#{g}'" do
      expect(chef_run).to create_group(g.to_s).with(gid: gid)
    end
  end
end
