default['conjur']['group']['conjurers']['name'] = 'conjurers'
default['conjur']['group']['conjurers']['gid'] = 50000
default['conjur']['group']['users']['name'] = 'users'
default['conjur']['group']['users']['gid'] = 5000
# Also supported: runit
default['conjur']['service_provider'] = 'upstart'
# Also supported: syslog-ng
default['conjur']['syslog_provider'] = 'rsyslog'
default['conjur']['sshd']['debug'] = false

# These attributes are used only by the conjurrc recipe, which can be used
# to install the initial Conjur configuration and certificate.
default['conjur']['configuration']['account'] = nil
default['conjur']['configuration']['appliance_url'] = nil
default['conjur']['configuration']['ssl_certificate'] = nil
default['conjur']['configuration']['plugins'] = []
