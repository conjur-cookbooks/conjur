service 'rsyslog' do
  provider Chef::Provider::Service::Upstart if node.platform == 'ubuntu'
end

file '/etc/rsyslog.d/94-logshipper.conf' do
  content "auth,authpriv.* |#{fifo_path};RSYSLOG_SyslogProtocol23Format\n"
  notifies :restart, 'service[rsyslog]'
end
