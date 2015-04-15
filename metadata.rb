name             'conjur'
maintainer       'Conjur, Inc'
maintainer_email 'support@conjur.net'
license          'MIT License'
description      'Installs/Configures conjur'
version          '0.1.1'

recipe "conjur::install", "Installs Conjur base packages and configuration, suitable for a foundation image."

depends "apt"
depends "yum"
depends "sshd-service"

%w(ubuntu).each do |platform|
  supports platform
end
