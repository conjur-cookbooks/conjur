group node['conjur']['groupnames']['conjurers'] do
  gid 50000
end

group node['conjur']['groupnames']['users'] do
  gid 5000
end

group 'conjur' do
  action :create
  append true
end

user "logshipper" do
  system true
  shell '/bin/false'
  group "conjur"
end
