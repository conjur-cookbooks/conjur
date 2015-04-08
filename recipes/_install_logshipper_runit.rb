directory '/etc/service/logshipper' do
  recursive true
end

cookbook_file '/etc/service/logshipper/run' do
  source 'runit/logshipper.sh'
  owner 'root'
  group 'root'
  mode '0755'
end
