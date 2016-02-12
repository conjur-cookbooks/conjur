# Details of testing the Conjur recipes

Conjur uses various components of the ChefDK to validate and test the Conjur recipes. To make it easier to run these tests in a CI environment (e.g Jenkins), we package gems for the ChefDK components we use into a Docker image.

## jenkins.sh
Our Jenkins job runs `jenkins.sh`. It calls `build.sh` to build the cookbook, then `test.sh` to run all the tests.

## build.sh

`build.sh` first builds the Docker image that will be used to create the cookbook and run the tests. It creates a container from it and generates a new cookbook tarball if any of the cookbook files have been updated.

## test.sh

`test.sh` starts by obtaining the current user's Conjur credentials. It does this by creating an instance of the Conjur API and interrogating it for the credentials. These credentials will be used later to access the Conjur Docker registry, to obtain the latest Conjur appliance image.

The script passes the credentials on to `ci/test.rb`, the main test script.

## ci/test.rb

`ci/test.rb` begins by running `rubocop`, `foodcritic`, and `chefspec`. These ChefDK tools do some validation and unit testing, then save their results into `ci/reports`.

`ci/test.rb` next calls `ci/start_conjur.sh` which runs Vagrant to spin up an AWS EC2 instance that will host a Conjur appliance. Once the instance is running, `ci/test.rb` uses two scripts (installed on the instance) to bring up a Conjur appliance. `ci/remote/conjurize.sh` installs the user's credentials (from `test.sh` above). `ci/remote/start_conjur.sh` connects to the Conjur Docker registry, pulls the latest stable Conjur appliance image, and starts it. Once Conjur is up, it creates a layer for test hosts, as well as a hostfactory (and hostfactory token) to add those hosts to the layer.

Next, `ci/test.rb` moves on to using Test Kitchen. For each platform specified in `.kitchen.yml`, it uses `kitchen` to
 
  * create an EC2 instance
  * update `/etc/hosts` on the instance with the IP address of the Conjur appliance
  * create a Conjur `host` (using the hostfactory token)
  * converge the instance, using the `conjur::client`, `conjur::conjurrc`, `conjur::install`, and `conjur::configure` recipes
  * verify the instance

One of the specs run by `kitchen verify` ensures that at least one `ssh:login` audit event has been generated for the instance. This relies on the fact that `serverspec` uses `ssh` to run tests on the instance. After the `conjur::configure` recipe has been run, `logshipper` will be running, and remote logins will be audited.