name             'conjur'
maintainer       'Conjur, Inc'
maintainer_email 'support@conjur.net'
license          'MIT License'
description      'Installs/Configures conjur'
version          '0.3.4'

recipe "conjur::install", "Installs Conjur base packages and configuration, suitable for a foundation image."

depends "apt"
depends "yum"
depends "sshd-service"

depends 'selinux', '~> 0.9'
depends 'selinux_policy', '~>0.9'

%w(ubuntu centos amazon debian).each do |platform|
  supports platform
end
