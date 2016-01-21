# 0.3.4

* Fix login on Debian
* Install `conjur_authorized_keys` in `/opt/conjur/bin` instead of `/usr/local/bin`

# 0.3.3

* Correctly detect systemd on Debian

# 0.3.2

* Fix for debian (don't install ubuntu-specific package)

# 0.3.1

* Fix Amazon Linux support

# 0.3.0

* Systemd support

# 0.2.3

* Updated EL repository URL

# 0.2.2

* Add a timeout in pubkey fetcher to prevent lockout when Conjur is unreachable

# 0.2.1

* Lower nslcd's idle_timelimit to one second

# 0.2.0

* Configures `nsswitch` to use LDAP for group lookup. This enables the usage of Conjur for secondary groups.

