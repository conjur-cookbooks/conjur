include_recipe "sshd-service"

chef_gem 'netrc'

# This is used to cURL the public keys service
package "curl"

%w(nscd nslcd).each{|s| service s}

include_recipe "conjur::_users"
  
case node.platform_family
  when 'debian'
    include_recipe 'conjur::_install_debian'
  when 'rhel'
    include_recipe 'conjur::_install_rhel'
  else 
    raise "Unsupported platform family : #{node.platform_family}"
end

if node["platform"] == "centos"
  include_recipe 'conjur::_install_selinux'
end

include_recipe 'conjur::_install_ssh'
include_recipe 'conjur::_install_logshipper'
