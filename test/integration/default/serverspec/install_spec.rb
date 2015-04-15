require 'spec_helper'

describe group('conjur') do
  it { should exist }
end

describe user('authkeylookup') do
  it { should exist }
end

describe group('conjurers') do
  it { should exist }
  it { should have_gid(50000) }
end

describe group('users') do
  it { should exist }
  it { should have_gid(5000) }
end

describe package("debconf"), :if => os[:family] == 'debian' do
  it { should exist }
end

describe package("nss-pam-ldapd"), :if => os[:family] == 'rhel' do
  it { should exist }
end
