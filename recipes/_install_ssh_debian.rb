include_recipe 'apt'

# Answer the installer questions about LDAP server location, root name, etc
cookbook_file "/tmp/ldap.seed" do
  source "ldap.seed"
end

cookbook_file "/usr/share/pam-configs/mkhomedir" do
  source "mkhomedir"
end

execute "debconf-set-selections /tmp/ldap.seed"

case node['platform']
  when 'ubuntu'
    for pkg in %w(debconf nss-updatedb nscd libpam-mkhomedir auth-client-config ldap-utils ldap-client libpam-ldapd libnss-ldapd)
      package pkg do
        options "-qq"
      end
    end
  when 'debian'
    for pkg in %w(debconf nss-updatedb nscd libpam-mkhomedir ldap-utils ldap-client libpam-ldapd libnss-ldapd )
      package pkg do
        options "-qq"
      end
    end
  else
    raise "Unsupported platform : #{node['platform']}"
end

execute "pam-auth-update" do
  command "pam-auth-update --package"
  %w(nscd nslcd).each{ |s| notifies :restart, "service[#{s}]" }
end

apt_repository 'conjur' do
  uri 'http://apt.conjur.s3-website-us-east-1.amazonaws.com'
  components %w(main)
  distribution node['lsb']['codename']
  key "apt.key"
end

package 'logshipper'
