#
# Copyright (C) 2015 Conjur Inc
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

# This is not a normal cookbook, it's used mostly for testing.
# It immediately creates the files '/etc/conjur.conf' and '/etc/conjur-acct.pem'.

account = node['conjur']['configuration']['account']

conjurrc = {
  "account" => account,
  "appliance_url" => node['conjur']['configuration']['appliance_url'],
  "plugins" => node['conjur']['configuration']['plugins'].to_a,
  "netrc_path" => "/etc/conjur.identity",
  "cert_file" => "/etc/conjur-#{account}.pem"
}

file "/etc/conjur.conf" do
  content YAML.dump(conjurrc)
  mode "0644"
end.run_action(:create)

file "/etc/conjur-#{account}.pem" do
  content node['conjur']['configuration']['ssl_certificate']
  mode "0644"
end.run_action(:create)
