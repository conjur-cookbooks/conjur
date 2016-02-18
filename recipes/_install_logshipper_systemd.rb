cookbook_file '/etc/systemd/system/logshipper.service' do
  source 'systemd/logshipper.service'
  owner 'root'
  group 'root'
  mode '0644'
end
