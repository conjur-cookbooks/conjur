service 'logshipper' do
  action :nothing
  if node['platform'] == 'amazon' ||
      (node['platform_family'] == 'rhel' && ConjurDetect.platform_version?(node, '~>6.0'))
    provider Chef::Provider::Service::Upstart
  end
end

file "/etc/conjur.identity" do
  mode 0640
  group "conjur"
  atomic_update false

  content """
machine #{conjur_appliance_url}/authn
    login host/#{conjur_host_id}
    password #{conjur_host_api_key}
"""
  notifies(:enable, 'service[logshipper]', :delayed)
  notifies(:restart, 'service[logshipper]', :delayed)
end
