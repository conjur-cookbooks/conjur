#
# Cookbook Name:: conjur
# Recipe:: identity
#
#
# Copyright (c) 2015 Conjur Inc, All Rights Reserved.

# This is not a normal cookbook, it's used mostly for testing.
# It immediately creates the 'conjur' group and the file '/etc/conjur.identity'.

chef_gem 'netrc' do
  compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
end

group 'conjur' do
  append true
end.run_action(:create)

file "/etc/conjur.identity" do
  mode 0640
  group "conjur"
  atomic_update false

  content """
machine #{conjur_appliance_url}/authn
    login host/#{conjur_host_id node}
    password #{conjur_host_api_key node}
"""
end.run_action(:create)
