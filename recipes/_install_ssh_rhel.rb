package_list = %W(
  nscd
  openldap
  openldap-clients
  nss-pam-ldapd
  authconfig
  policycoreutils-python
  oddjob
)

if Chef::VersionConstraint.new('~> 7.0').include?(node['platform_version'])
  # this is needed for mkhomedir to work on rhel 7 and variants
  package_list << 'oddjob-mkhomedir'
  
  # this package doesn't exist anymore on rhel 7 in
  # the main repo and doesn't appear to be required
  # TODO: figure out if it can be removed altogether
  package_list -= ['openssl-perl']
end

package_list.each do |pkg|
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

# amazon linux uses 'current' as $releasever
# but packages from EL7 work on it.
# CentOS and RHEL actually have '6' or '7' in the variable.
releasever = {
  'amazon' => '7'
}[node['platform']] || '$releasever'

yum_repository 'conjur' do
  description 'Conjur Inc.'
  baseurl "https://s3.amazonaws.com/yum.conjur/el/#{releasever}"
  gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Conjur'
end

package 'logshipper'
