default['conjur']['group']['conjurers']['name'] = 'conjurers'
default['conjur']['group']['conjurers']['gid'] = 50000
default['conjur']['group']['users']['name'] = 'users'
default['conjur']['group']['users']['gid'] = 5000
# Supported: runit, upstart. Default autodetected.
default['conjur']['service_provider'] = ConjurDetect.detect_init
# Supported: rsyslog, syslog-ng. Default autodetected.
default['conjur']['syslog_provider'] = ConjurDetect.detect_syslog
# Write a sudoers.d which gives passwordless sudo to the 'conjurers' group
default['conjur']['grant_passwordless_sudo_to_conjurers'] = true
default['conjur']['selinux_enabled'] = ConjurDetect.selinux_enabled?
# Configure verbose logging for SSHD
default['conjur']['sshd']['debug'] = false

# These attributes are used only by the client.rb recipe
default['conjur']['client']['version'] = '4.29.0-1'

# These attributes are used only by the conjurrc recipe, which can be used
# to install the initial Conjur configuration and certificate.
default['conjur']['configuration']['account'] = nil
default['conjur']['configuration']['appliance_url'] = nil
default['conjur']['configuration']['ssl_certificate'] = nil
default['conjur']['configuration']['plugins'] = []
