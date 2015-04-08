default['conjur']['group']['conjurers']['name'] = 'conjurers'
default['conjur']['group']['conjurers']['gid'] = 50000
default['conjur']['group']['users']['name'] = 'users'
default['conjur']['group']['users']['gid'] = 5000
# Also supported: runit
default['conjur']['service_provider'] = 'upstart'
# Also supported: syslog-ng
default['conjur']['syslog_provider'] = 'rsyslog'
default['conjur']['sshd']['debug'] = false