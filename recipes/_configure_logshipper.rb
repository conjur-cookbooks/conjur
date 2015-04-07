service_provider = node['conjur']['service_provider']
include_recipe "conjur::_configure_logshipper_#{service_provider}"

service_provider = node['conjur']['syslog_provider']
include_recipe "conjur::_configure_logshipper_#{syslog_provider}"
