service 'syslog' do
  service_name 'rsyslog'
end

file '/etc/rsyslog.d/94-logshipper.conf' do
  content "auth,authpriv.* |#{logshipper_fifo_path};RSYSLOG_SyslogProtocol23Format\n"
  notifies :restart, 'service[syslog]'
end
