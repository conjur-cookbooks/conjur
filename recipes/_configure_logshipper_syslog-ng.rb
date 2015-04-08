service 'syslog' do
  provider Chef::Provider::Service::Upstart if node.platform == 'ubuntu'
  service_name 'syslog-ng'
end

cookbook_file '/etc/syslog-ng/conf.d/logshipper.conf' do
  source 'syslog-ng/logshipper.conf'
  owner 'root'
  group 'root'
  mode '0644'
end
