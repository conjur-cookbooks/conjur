case node['platform_family']
  when 'debian'
    include_recipe 'conjur::_client_debian'
  when 'rhel', 'amazon'
    include_recipe 'conjur::_client_rhel'
  else
    raise "Unsupported platform family : #{node['platform_family']}"
end
