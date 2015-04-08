group node.conjur.group.conjurers.name do
  gid node.conjur.group.conjurers.gid.to_i
end

group node.conjur.group.users.name do
  gid node.conjur.group.users.gid.to_i
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

user "authkeylookup" do
  system true
  shell "/bin/false"
end
