if node.conjur.service_provider == "upstart"
  service 'logshipper' do
    provider Chef::Provider::Service::Upstart
    action :nothing
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
  notifies :restart, 'service[logshipper]', :delayed if node.conjur.service_provider == "upstart"
end
