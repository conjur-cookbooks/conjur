chef_gem 'netrc' do
  compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
end

group 'conjur' do
  action :create
  append true
end

include_recipe "apt"
include_recipe 'conjur::_install_ssh'
include_recipe 'conjur::_install_logshipper'
