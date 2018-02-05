include_recipe 'apt'

# Answer the installer questions about LDAP server location, root name, etc
cookbook_file "/tmp/ldap.seed" do
  source "ldap.seed"
end

execute "debconf-set-selections /tmp/ldap.seed"

pkgs = %w(debconf nss-updatedb nscd libpam-mkhomedir ldap-utils ldap-client libpam-ldapd libnss-ldapd)
if node['platform'] == 'ubuntu'
  pkgs << 'auth-client-config'
end
for pkg in pkgs
      package pkg do
        options "-qq"
      end
    end

cookbook_file "/usr/share/pam-configs/mkhomedir" do
  source "mkhomedir"
end

# pam-auth-update is broken on xenial, see
# https://bugs.launchpad.net/ubuntu/+source/pam/+bug/682662
execute 'workaround Ubuntu bug #682662' do
  command "sed -i '/mkhomedir/d' /var/lib/pam/seen"
  only_if do
    # annoyingly the bug is marked WONTFIX so might as well do it for all ubuntus >= 16.04
    [
      (node['platform'] == 'ubuntu'),
      (node['platform_version'] >= '16.04'),
      File.exists?('/var/lib/pam/seen'),
    ].all?
  end
end

execute "pam-auth-update" do
  command "pam-auth-update --package"
  %w(nscd nslcd).each{ |s| notifies :restart, "service[#{s}]" }
end

apt_repository 'conjur' do
  uri 'http://apt.conjur.org'
  components %w(main)
  distribution node['lsb']['codename']
  key "apt.key"
  only_if { node['conjur']['logshipper']['conjur_repository'] }
end

package 'logshipper'
