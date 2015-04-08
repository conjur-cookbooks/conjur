service_provider = node['conjur']['service_provider']
include_recipe "conjur::_configure_logshipper_#{service_provider}"
