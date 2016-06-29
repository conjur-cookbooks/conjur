user "logshipper" do
  system true
  shell '/bin/false'
  group "conjur"
end

service 'logshipper' do
  action :disable
end

service_provider = node['conjur']['service_provider']
include_recipe "conjur::_install_logshipper_#{service_provider}"

syslog_provider = node['conjur']['syslog_provider']
include_recipe "conjur::_install_logshipper_#{syslog_provider}"

if node['etc']['group'].include? 'syslog'
  fifo_group = 'syslog'
else
  fifo_group = 'root'
end

bash "mkfifo #{logshipper_fifo_path}" do
  not_if { begin
    s = File.stat(logshipper_fifo_path)
    [
      s.pipe?,
      (s.mode & 0777 == 0460),
      s.uid == node['etc']['passwd']['logshipper'].uid,
      s.gid == node['etc']['group'][fifo_group].gid,
    ].all?
  rescue Errno::ENOENT, NoMethodError
    false
  end }

  code """
    rm -f #{logshipper_fifo_path}
    mkfifo --mode=0460 #{logshipper_fifo_path}
    chown logshipper:#{fifo_group} #{logshipper_fifo_path}
"""
  notifies(:restart, 'service[syslog]', :delayed)
end


file "/var/log/logshipper.log" do
  owner 'logshipper'
  mode '0640'
end
