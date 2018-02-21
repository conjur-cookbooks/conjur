# 0.4.5

* Fix some issues on Ubuntu 16.04 preventing mkhomedir and logshipper from working correctly.

# 0.4.4

* Change repository addresses to {apt,yum}.conjur.org.

# 0.4.3

* Added attribute `['conjur']['logshipper']['conjur_repository']` to toggle pulling
packages from Conjur repos in [offline scenarios](OFFLINE.md).

# 0.4.2

* Don't install any packages in the `configure` step.

# 0.4.1

* On platforms that use systemd, don't try to restart logshipper in conjur::install

# 0.4.0

* Add automated testing for many more platforms
* Rework testing use a real Conjur appliance

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

