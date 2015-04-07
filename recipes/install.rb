include_recipe "sshd-service"

chef_gem 'netrc'

# This is used to cURL the public keys service
package "curl"

%w(nscd nslcd).each{|s| service s}

include_recipe "conjur::_users"
  
case node[:platform_family]
  when 'debian'
    include_recipe 'conjur::install_debian'
  when 'rhel'
    include_recipe 'conjur::install_rhel'
  else 
    raise "Unsupported platform family : #{node[:platform_family]}"
end

if node[:platform] == "centos"
  include_recipe 'conjur::install_selinux'
end

ruby_block "Enable DEBUG logging for sshd" do
  block do
    edit = Chef::Util::FileEdit.new('/etc/ssh/sshd_config')
    edit.search_file_replace_line "LogLevel INFO", "LogLevel DEBUG"
    edit.write_file
  end
  notifies :restart, "service[#{node.sshd_service.service}]"
  only_if { node.conjur.terminal_login['debug'] }
end

# Need this because there's not going to be a homedir the first time we 
# login.  Without this the first attempt to ssh to the host will fail.
ruby_block "Tell sshd not to print the last login" do
  block do
    edit = Chef::Util::FileEdit.new '/etc/ssh/sshd_config'
    edit.search_file_replace_line "PrintLastLog yes", "PrintLastLog no"
    edit.write_file
  end
  notifies :restart, "service[#{node.sshd_service.service}]"
end

user "authkeylookup" do
  system true
  shell "/bin/false"
end

ruby_block "Configure sshd with AuthorizedKeysCommand" do
  block do
    ssh_version = `ssh -V 2>&1`.split("\n")[0]
    raise "Can't detect ssh version" unless ssh_version && ssh_version =~ /OpenSSH_([\d\.]+)/
    ssh_version = $1

    run_as_option = case ssh_version
      when /^5\./, '6.0'
        'AuthorizedKeysCommandRunAs'
      else
        'AuthorizedKeysCommandUser'
    end

    edit = Chef::Util::FileEdit.new('/etc/ssh/sshd_config')
    
    edit.insert_line_after_match(/#?AuthorizedKeysFile/, <<-CMD)
AuthorizedKeysCommand /usr/local/bin/conjur_authorized_keys
#{run_as_option} authkeylookup
    CMD
    edit.write_file
    Chef::Log.info "Wrote AuthorizedKeysCommand into sshd_config"
  end
  # Need this so the lines don't get inserted multiple times
  not_if { File.read('/etc/ssh/sshd_config').index('AuthorizedKeysCommand /usr/local/bin/conjur_authorized_keys') }
  notifies :restart, "service[#{node.sshd_service.service}]"
end

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
end

file "/var/log/logshipper.log" do
  owner 'logshipper'
  mode '0640'
end
