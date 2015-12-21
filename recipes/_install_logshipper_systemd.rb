cookbook_file '/etc/systemd/system/logshipper.service' do
  source 'systemd/logshipper.service'
  owner 'root'
  group 'root'
  mode '0755'
end

bash 'enable and run logshipper' do
  code """
    systemctl enable logshipper
    systemctl start logshipper
  """
end
