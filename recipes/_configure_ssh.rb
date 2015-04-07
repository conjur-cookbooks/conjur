chef_gem 'netrc'

%w(nscd nslcd).each do |s| 
  service s do
    action :enable
  end
end

openldap_dir = case node[:platform_family]
  when 'debian'
    '/etc/ldap'
  when 'rhel'
    '/etc/openldap'
  else 
    raise "Unsupported platform family : #{node[:platform_family]}"
end

template "#{openldap_dir}/ldap.conf" do
  source "ldap.conf.erb"
  variables account: conjur_account,
    host_id: conjur_host_id,
    uri: conjur_ldap_url,
    cacertfile: conjur_cacertfile
  mode "0644"
end

template "/etc/nslcd.conf" do
  source "nslcd.conf.erb"
  gid = case node[:platform_family]
    when 'debian'
      'nslcd'
    when 'rhel'
      'ldap'
    else 
      raise "Unsupported platform family : #{node[:platform_family]}"
  end
  variables account: conjur_account, 
    host_id: conjur_host_id, 
    host_api_key: conjur_host_api_key, 
    gid: gid, 
    uri: conjur_ldap_url,
    cacertfile: conjur_cacertfile
  %w(nscd nslcd).each{ |s| notifies :restart, "service[#{s}]" }
end

template "/usr/local/bin/conjur_authorized_keys" do
  curl_options = []
  curl_options << "--cacert #{conjur_cacertfile}" if conjur_cacertfile
  
  source "conjur_authorized_keys.sh.erb"
  variables uri: conjur_authorized_keys_command_url, options: curl_options.join(' ')
  mode "0755"
  %w(nscd nslcd).each{ |s| notifies :restart, "service[#{s}]" }
end
