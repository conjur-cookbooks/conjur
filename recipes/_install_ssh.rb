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

ruby_block "Configure sshd with AuthorizedKeysCommand" do
  block do
    ssh_version = Mixlib::ShellOut.new(%Q(ssh -V 2>&1)).run_command.split("\n")[0]
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
