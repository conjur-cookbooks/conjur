########
# SSH

# Name of the Unix group corresponding to Conjur `update` privilege
default['conjur']['group']['conjurers']['name'] = 'conjurers'

# GID number of the Unix group corresponding to Conjur `update` privilege
default['conjur']['group']['conjurers']['gid'] = 50000

# Name of the Unix group corresponding to Conjur `execute` privilege
default['conjur']['group']['users']['name'] = 'users'

# GID number of the Unix group corresponding to Conjur `execute` privilege
default['conjur']['group']['users']['gid'] = 5000

# Service provider to use for `logshipper`
# Supported: runit, upstart. Default autodetected.
default['conjur']['service_provider'] = ConjurDetect.detect_init

# Syslog provider which is used on the machine, and will be hooked up to `logshipper`
# Supported: rsyslog, syslog-ng. Default autodetected.
default['conjur']['syslog_provider'] = ConjurDetect.detect_syslog

# Whether to grant passwordless `sudo` privilege to the `conjurers`
# group to adding a config file to sudoers.d
default['conjur']['grant_passwordless_sudo_to_conjurers'] = true

# Enable debug logging of `sshd`
default['conjur']['sshd']['debug'] = false

# true if selinux is enabled on the node. Default autodetected
default['conjur']['selinux_enabled'] = ConjurDetect.selinux_enabled?

########
# Logshipper installation

# Whether to set up Conjur's package repositories to install packages online.
# This can be disabled eg. in restricted network scenarios, where packages are
# preinstalled or mirrored to another preconfigured (eg. internal) repository.
default['conjur']['logshipper']['conjur_repository'] = true

########
# Conjur client installation

# The version of the Conjur client to be installed. This attribute are
# used only by the client.rb recipe
default['conjur']['client']['version'] = '4.29.0-1'

########
# Conjur client configuration

# These attributes are used only by the conjurrc recipe, which can be used
# to install the initial Conjur configuration and certificate.

# Conjur organization account
default['conjur']['configuration']['account'] = nil

# URL to the Conjur appliance, in the form `https://conjur/api`.
default['conjur']['configuration']['appliance_url'] = nil

# Conjur server SSL certificate
default['conjur']['configuration']['ssl_certificate'] = nil

# List of activated CLI plugins
default['conjur']['configuration']['plugins'] = []
