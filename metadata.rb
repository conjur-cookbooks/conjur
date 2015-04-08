name             'conjur'
maintainer       'Conjur, Inc'
maintainer_email 'support@conjur.net'
license          'MIT License'
description      'Installs/Configures conjur'
version          '1.0.0'

recipe "conjur::install", "Installs Conjur base packages and configuration, suitable for a foundation image."

depends "sshd-service"

%w(debian ubuntu centos fedora).each do |platform|
  supports platform
end
