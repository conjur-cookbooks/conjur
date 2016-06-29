include_recipe "sshd-service"

chef_gem 'netrc' do
  compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
end

%w(nscd nslcd).each do |s|
  service s do
    action :nothing
  end
end

# This is used to cURL the public keys service
package "curl"

group node['conjur']['group']['conjurers']['name'] do
  gid node['conjur']['group']['conjurers']['gid'].to_i
end

group node['conjur']['group']['users']['name'] do
  gid node['conjur']['group']['users']['gid'].to_i
end

user "authkeylookup" do
  system true
  shell "/bin/false"
end

case node['platform_family']
  when 'debian'
    include_recipe 'conjur::_install_ssh_debian'
  when 'rhel'
    include_recipe 'conjur::_install_ssh_rhel'
  else
    raise "Unsupported platform family : #{node['platform_family']}"
end

if node["platform_family"] == "rhel" && node['conjur']['selinux_enabled']
  include_recipe 'conjur::_install_selinux'
end

# Need this because there's not going to be a homedir the first time we
# login.  Without this the first attempt to ssh to the host will fail.
ruby_block "Tell sshd not to print the last login" do
  block do
    edit = Chef::Util::FileEdit.new '/etc/ssh/sshd_config'
    edit.search_file_replace_line "PrintLastLog yes", "PrintLastLog no"
    edit.write_file
  end
  notifies :restart, "service[#{node['sshd_service']['service']}]"
end

ruby_block "Configure sshd with AuthorizedKeysCommand" do
  block do
    ssh_version = Mixlib::ShellOut.new(%Q(ssh -V 2>&1)).run_command
    ssh_version.error!
    ssh_version = ssh_version.stdout.split("\n")[0]
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
AuthorizedKeysCommand /opt/conjur/bin/conjur_authorized_keys
#{run_as_option} authkeylookup
    CMD
    edit.write_file
    Chef::Log.info "Wrote AuthorizedKeysCommand into sshd_config"
  end
  # Need this so the lines don't get inserted multiple times
  not_if { File.read('/etc/ssh/sshd_config').index('AuthorizedKeysCommand /opt/conjur/bin/conjur_authorized_keys') }
  notifies :restart, "service[#{node['sshd_service']['service']}]"
end
