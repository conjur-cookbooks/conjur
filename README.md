# conjur

Installs and/or configures Conjur, including Conjur SSH and command-line tools.

This cookbook is composed of several recipes, which can be used at different stages of the continuous delivery lifecycle.

The lifecycle is roughly intended to operate like this:

* A base OS image from the CentOS or Ubuntu LTS family is selected. 
* The "foundation" cookbooks run on the base OS image to configure the connection to Conjur (and other desired systems), install packages, and perform static configuration.
* A "foundation" image is captured after the foundation cookbooks have completed.
* Machines are launched from the "foundation" image. Each machine is provided with Conjur identity, then a Chef run finishes the machine configuration (e.g. configure the host credentials for LDAPS connection to Conjur). At this point, Chef (or other configuration management tools) may also install and configure applications on top of the base OS foundation.

### Foundation Recipes

These recipes can be used to build a "foundation" image, which is able to create a secure connection to Conjur, and has performed all package installation prior to the machine launch.

* **install [required]** Installs base packages which are needed for Conjur SSH. All installation and configuration steps performed by this recipe can be built into an image.
* **conjurrc [optiona]** Configures the connection to the Conjur server endpoint and establishes SSL verification. This information can be safely built into an image.
* **client [optional]** Installs the Conjur command-line tools. This is optional for Conjur SSH functionality. The CLI can be built into an image.

### Launch recipes

* **configure** Applies the Conjur host identity to finish the machine configuration.

## Requirements

### Platforms

* Ubuntu 12.04 LTS
* Ubuntu 14.04 LTS

### Dependency Cookbooks

* `sshd-service`

## Attributes

See `attributes/default.rb` for defaults.

### SSH

The following attributes pertain to login (ssh) functionality.

* `node['conjur']['group']['conjurers']['name']` Name of the Unix group corresponding to Conjur `update` privilege
* `node['conjur']['group']['conjurers']['gid']` GID number of the Unix group corresponding to Conjur `update` privilege
* `node['conjur']['group']['users']['name']` Name of the Unix group corresponding to Conjur `execute` privilege
* `node['conjur']['group']['users']['gid']` GID number of the Unix group corresponding to Conjur `execute` privilege
* `node['conjur']['service_provider']` Service provider to use for `logshipper`
* `node['conjur']['syslog_provider']` Syslog provider which is used on the machine, and will be hooked up to `logshipper`
* `node['conjur'['grant_passwordless_sudo_to_conjurers']` Whether to grant passwordless `sudo` privilege to the `conjurers` group.
* `node['conjur']['sshd']['debug']` Enable debug logging of `sshd`

### Conjur client tools

The following attributes pertain to installation of the [Conjur command-line tools](http://developer.conjur.net/client_setup/cli.html):

* `node['conjur']['client']['version']` Installer version of Conjur CLI tools (optional)

### Conjur connection configuration and SSL verification

The following attributes can be used to configure the secure connection to the Conjur server:

* `node['conjur']['configuration']['account']` Conjur organization account
* `node['conjur']['configuration']['appliance_url']` URL to the Conjur appliance, in the form `https://conjur/api`.
* `node['conjur']['configuration']['ssl_certificate']` Conjur server SSL certificate
* `node['conjur']['configuration']['plugins']` List of activated CLI plugins

## Recipes

### default

Runs the `install` and `configure` recipes.

### install

Installs packages required for Conjur SSH. Packages install include:

* openssh
* PAM + LDAP
* Conjur `logshipper`, which receives `auth.log` lines from `syslog`, parses them, and sends them to Conjur as `login`, `logout`, and `sudo` records.

This recipe also applies base configuration, such as:

* Conjur `update` permission is mapped to a Unix user group
* Conjur `execute` permission is mapped to a Unix user group
* By default, the `update` Unix group is granted passwordless sudo access

### client

Installs the Conjur command-line tools.

### conjurrc

Creates the `/etc/conjur.conf` and `/etc/conjur-[acct].pem` from Chef attributes.

## Tests

This cookbook is verified by both `chefspec` and `serverspec` tests. Conjur Inc also verifies the correct operation of the SSH functionality on all supported platforms. More details about testing can be found in README.ci.md.
