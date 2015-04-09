group 'conjur' do
  action :create
  append true
end

include_recipe "conjur::_configure_ssh"
include_recipe "conjur::_configure_logshipper"
