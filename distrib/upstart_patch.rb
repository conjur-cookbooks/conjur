# Patch the Upstart provider so that it works also when upstart is not running.
# This is useful when converging in docker.
class Chef::Provider::Service::Upstart
  alias_method :start_service_without_check, :start_service

  def start_service
    start_service_without_check if upstart_running?
  end

  def upstart_running?
    ::File.read('/proc/1/cmdline').strip == '/sbin/init'
  end
end
