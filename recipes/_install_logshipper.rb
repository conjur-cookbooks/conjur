fifo_path = '/var/run/logshipper'
if node.etc.group.include? 'syslog'
  fifo_group = 'syslog'
else
  fifo_group = 'root'
end

bash "mkfifo #{fifo_path}" do
  not_if { begin
    s = File.stat(fifo_path)
    [
      s.pipe?,
      (s.mode & 0777 == 0460),
      s.uid == node.etc.passwd.logshipper.uid,
      s.gid == node.etc.group[fifo_group].gid,
    ].all?
  rescue Errno::ENOENT, NoMethodError
    false
  end }

  code """
    rm -f #{fifo_path}
    mkfifo --mode=0460 #{fifo_path}
    chown logshipper:#{fifo_group} #{fifo_path}
  """
  
  # we need to restart as the pipe has moved
  notifies :restart, 'service[logshipper]', :delayed
  notifies :restart, 'service[syslog]', :delayed
end

file "/var/log/logshipper.log" do
  owner 'logshipper'
  mode '0640'
end
