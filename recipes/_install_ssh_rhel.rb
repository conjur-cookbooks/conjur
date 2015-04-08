%w(nscd openldap openldap-clients nss-pam-ldapd authconfig openssl-perl policycoreutils-python).each do |pkg|
  package pkg do
    options '-y'
  end
end

execute "authconfig" do
  command "authconfig --enablecache --enableldap --disableldapauth --enablemkhomedir --updateall"
  notifies :restart, "service[nslcd]"
end

cookbook_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-Conjur' do
  mode '644'
  source 'apt.key'
end

yum_repository 'conjur' do
  description 'Conjur Inc.'
  baseurl 'http://yum.conjur.s3-website-us-east-1.amazonaws.com'
  gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Conjur'
end

package 'logshipper'
