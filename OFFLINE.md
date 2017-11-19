# Offline conjurize instructions

Machines behind a firewall can be assigned a Conjur identity, but some initial setup is required. As detailed in [README.md](README.md), all package installation is done in the 'Foundation' recipes: `install`, `conjurrc`, and optionally `client`. These end state of these recipes (installed packages and static configuration files) can be baked into a base image, they will not change. Once a machine has been assigned an identity, the `configure` recipe is run to finish setup. `configure` does not require network access, other than to your Conjur endpoint.

---

## Chef + conjurize

Since this is a Chef cookbook, the Chef client and cookbooks need to be downloaded and available on the target system, the machine to be conjurized. The Chef client can be installed [from here](https://downloads.chef.io/chef-client/). Once the Chef client has been pre-installed on a machine, `conjurize` (see below) can be told to point to it.

The `conjur` cookbook and all dependency cookbooks can be downloaded as a tarball from this GitHub repo. Download the latest tar.gz file [from this repository's Releases](https://github.com/conjur-cookbooks/conjur/releases) to a local directory or upload it to an internal file server.

Shipped with the [Conjur CLI](https://developer.conjur.net/cli), the [conjurize tool](https://developer.conjur.net/reference/tools/utilities/conjurize.html) has two flags that allow you to use a local Chef install and cookbook tarball, instead of pulling them from the internet. Note that these flags are relative to paths on the **target** system, not the system running conjurize.

*Example: Create a host and pass it through conjurize, using local flags:*

```
$ conjur host create myhost01 | tee host.json

{
  "id": "myhost01",
  "userid": "dustin",
  "created_at": "2016-07-06T18:04:23Z",
  "ownerid": "myorg:user:dustin",
  "roleid": "myorg:host:myhost01",
  "resource_identifier": "myorg:host:myhost01",
  "api_key": "3687gvknscext697rg6shvz3w777g03xeq8b63c4xx422m2s5ep"
}

# Generate the conjurize script, note that --conjur-cookbook-url can also be a local path
$ cat host.json | \
  conjurize --sudo --ssh \
  --chef-executable /bin/chef-solo \
  --conjur-cookbook-url https://www.myorg.com/conjur-v0.4.2-1-ga813184.tar.gz

#!/bin/sh
set -e

# Implementation note: 'tee' is used as a sudo-friendly 'cat' to populate a file with the contents provided below.

sudo -n tee /etc/conjur.conf > /dev/null << EOF
account: myorg
appliance_url: https://conjur.myorg.com/api
cert_file: /etc/conjur-myorg.pem
netrc_path: /etc/conjur.identity
plugins: []
EOF

sudo -n tee /etc/conjur-myorg.pem > /dev/null << EOF
-----BEGIN CERTIFICATE-----
...truncated
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
...truncated
-----END CERTIFICATE-----
EOF

sudo -n touch /etc/conjur.identity
sudo -n chmod 600 /etc/conjur.identity
sudo -n tee /etc/conjur.identity > /dev/null << EOF
machine https://conjur.myorg.com/api/authn
        login host/testhost001
        password 3687gvknscext697rg6shvz3w777g03xeq8b63c4xx422m2s5ep
EOF


sudo -n /usr/bin/chef --recipe-url https://www.myorg.com/conjur-v0.4.2-1-ga813184.tar.gz -o conjur
```

This script can then be placed on the machine and run, or executed directly over SSH.

```
cat host.json | conjurize ..args | ssh -tt myuser@myhost01.myorg.com
```

Note that if you don't require Conjur's SSH access management for your machines, you can omit conjurize's `--ssh` flag. This makes the above script much simpler, and doesn't require a Chef client install or running any cookbooks. 

---

## Host Factory

conjurize is a good tool for assigning Conjur identity to one-off instances, but we recommend using [Host Factory](https://developer.conjur.net/reference/services/host_factory/) for assigning host identity at scale. Host Factory allows you to exchange secure tokens for host identity in specific layers. Hosts assume any permissions of the layers they enter.

To prepare hosts for Host Factory, it is best to bake the installation and configuration of  packages required for Conjur host identity. Conjur configuration is set up in the base image you use to launch VMs from, whether you use Amazon AMIs, VMware, etc. In this pattern, the only steps that need to be run on machine launch are 1. assigning identity and 2. finalizing Conjur configuration. 

*Example: Bake a base image with Conjur packages and configuration:*

[chef-solo](https://docs.chef.io/chef_solo.html) can be used to set Conjur configuration and run cookbooks that install required packages. Replace the example configuration with your own. Note that none of this configuration is sensitive, you can check it into source control. `ssl_certificate` refers to the public SSL cert used to connect to Conjur.

**Foundation**

```
$ cat > attribs.json <<EOF
{
  "run_list": ["conjur::install", "conjur::conjurrc"],
  "conjur": {
    "configuration": {
      "account": "myorg",
      "appliance_url": "https://conjur.myorg.com/api",
      "ssl_certificate": "-----BEGIN CERTIFICATE-----..."
    }
  }
}
EOF

$ chef-solo -o --json-attributes attribs.json \
  --recipe-url https://www.myorg.com/conjur-v0.4.2-1-ga813184.tar.gz
```

**Launch**

Note that this requires the [jq](https://stedolan.github.io/jq/) tool to parse the Conjur API response. Install it in the 'Foundation' step. The following script should be run as `root` user. Update this script to fit your needs.

```
#!/bin/bash -e

HOST_FACTORY_TOKEN=asdp98cnm...  # Distribution depends on your setup
HOST_ID=myhost001  # Can also come from machine's metadata
ENDPOINT=https://conjur.myorg.com/api

# Use the public SSL cert to make a call to the Conjur API
PEMPATH=$(ls /etc/conjur-*.pem)

curl -s -X POST \
  --cacert $PEMPATH \
  -H "Authorization: Token token=\"$HOST_FACTORY_TOKEN\"" \
  "https://$ENDPOINT/host_factories/hosts?id=$HOST_ID" \
  -o response.json

HOSTFACTORY=$(cat response.json | jq -r .userid | cut -d'/' -f2-)
APIKEY=$(cat response.json | jq -r .api_key)
ORGACCOUNT=$(cat response.json | jq -r .roleid | cut -d':' -f1)

echo "Creating host '$HOST_ID' with Host Factory '$HOSTFACTORY'."
echo "Writing identity file."
cat << EOF > /etc/conjur.identity
machine https://$ENDPOINT/authn
    login host/$HOST_ID
    password $APIKEY
EOF
chown root:conjur /etc/conjur.identity
chmod 640 /etc/conjur.identity

cat > attribs.json <<EOF
{
  "run_list": ["conjur::configure"],
  "conjur": {
    "configuration": {
      "account": "myorg",
      "appliance_url": "https://conjur.myorg.com",
      "ssl_certificate": "-----BEGIN CERTIFICATE-----..."
    }
  }
}
EOF

chef-solo -o --json-attributes attribs.json \
  --recipe-url https://www.myorg.com/conjur-v0.4.2-1-ga813184.tar.gz
```

---

## Dependencies

If an outgoing internet connection is not available when building the 'Foundation' image, system dependencies will need to be vendored as well. This means deconstructing the Chef cookbook. Following are a list of dependencies by platform.

### CentOS/RHEL

- netrc (Ruby gem, must be installed into Chef's embedded Ruby)
- curl
- nscd
- openldap
- openldap-clients
- nss-pam-ldapd
- authconfig
- policycoreutils-python
- oddjob
- oddjob-mkhomedir (RHEL7 + variants only)
- openssh-clients 
- openssh

#### Logshipper

Logshipper binary packages are required for auditing ssh events and are installed by the cookbook from Conjur-managed apt and yum repos.
Adding the repo and installing logshipper can also be accomplished manually. If installing
manually, set the Chef attribute `['conjur']['logshipper']['conjur_repository']` to `false`
when running the cookbook.

For example in Enterprise Linux:

```
# yum-config-manager --add-repo https://s3.amazonaws.com/yum.conjur.org/conjur.repo
# yum-config-manager --enable conjur
# yum install logshipper
```

On CentOS 7 this will install packages from the Conjur repo like:

- [logshipper-0.2.3-1.el7.x86_64.rpm](https://s3.amazonaws.com/yum.conjur.org/el/7/x86_64/logshipper-0.2.3-1.el7.x86_64.rpm),
- [yaml-cpp-0.5.1-6.el7.x86_64.rpm](https://s3.amazonaws.com/yum.conjur.org/el/7/x86_64/yaml-cpp-0.5.1-6.el7.x86_64.rpm),
- [jsoncpp-0.6.0-0.9.rc2.el7.x86_64.rpm](https://s3.amazonaws.com/yum.conjur.org/el/7/x86_64/jsoncpp-0.6.0-0.9.rc2.el7.x86_64.rpm),

along with dependencies from the system repository:

- boost-filesystem
- boost-program-options
- boost-regex
- boost-system
- libicu

and the [build@conjur.net package signing key](https://pgp.mit.edu/pks/lookup?op=vindex&search=0xBE332A6015C7B700)  (fingerprint 5C222DDC0332C87E2EE2430FBE332A6015C7B700).
