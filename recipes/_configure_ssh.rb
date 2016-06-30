include_recipe "sshd-service"

%w(nscd nslcd).each do |s| 
  service s do
    action :nothing
  end
end

template "/etc/sudoers.d/conjurers" do
  source "sudoers.d_conjurers.erb"
  mode 0440

  only_if { node['conjur']['grant_passwordless_sudo_to_conjurers'] == true }
end

ruby_block "Enable DEBUG logging for sshd" do
  block do
    edit = Chef::Util::FileEdit.new('/etc/ssh/sshd_config')
    edit.search_file_replace_line "LogLevel INFO", "LogLevel DEBUG"
    edit.write_file
  end
  notifies :restart, "service[#{node['sshd_service']['service']}]"
  only_if { node['conjur']['sshd']['debug'] }
end

openldap_dir = case node['platform_family']
  when 'debian'
    '/etc/ldap'
  when 'rhel'
    '/etc/openldap'
  else 
    raise "Unsupported platform family : #{node['platform_family']}"
end

template "#{openldap_dir}/ldap.conf" do
  source "ldap.conf.erb"
  variables account: conjur_account,
    host_id: conjur_host_id,
    uri: conjur_ldap_url,
    cacertfile: conjur_cacertfile
  mode "0644"
end

nslcd_gid = case node['platform_family']
  when 'debian'
    'nslcd'
  when 'rhel'
    'ldap'
  else 
    raise "Unsupported platform family : #{node['platform_family']}"
end

template "/etc/nslcd.conf" do
  source "nslcd.conf.erb"
  variables account: conjur_account, 
    host_id: conjur_host_id, 
    host_api_key: conjur_host_api_key, 
    gid: nslcd_gid,
    uri: conjur_ldap_url,
    cacertfile: conjur_cacertfile
  notifies :restart, "service[nscd]"
  notifies :restart, "service[nslcd]"
end

%w[ /opt /opt/conjur /opt/conjur/bin ].each do |d|
  directory d do
    owner 'root'
    group 'root'
    mode '0755'
  end
end

template "/opt/conjur/bin/conjur_authorized_keys" do
  curl_options = ["--connect-timeout 2"]
  curl_options << "--cacert #{conjur_cacertfile}" if conjur_cacertfile
  
  source "conjur_authorized_keys.sh.erb"
  variables uri: conjur_authorized_keys_command_url, options: curl_options.join(' ')
  mode "0755"
  %w(nscd nslcd).each{ |s| notifies :restart, "service[#{s}]" }
end
