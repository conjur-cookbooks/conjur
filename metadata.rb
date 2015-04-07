name             'conjur'
maintainer       'Conjur, Inc'
maintainer_email 'support@conjur.net'
license          'MIT License'
description      'Installs/Configures conjur'
version          '1.0.0'

recipe "conjur::install", "Installs Conjur base packages and configuration, suitable for a foundation image."

attribute 'conjur/groupnames/conjurers',
  default: 'conjurers'
attribute 'conjur/groupnames/users',
  default: 'users'
attribute 'conjur/service_provider',
  default: 'upstart',
  choice: %w(upstart runit)
attribute 'conjur/syslog_provider',
  default: 'rsyslog',
  choice: %w(rsyslog syslog-ng)
  
%w(debian ubuntu centos fedora).each do |platform|
  supports platform
end
