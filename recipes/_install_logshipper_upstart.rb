command_line = "/usr/sbin/logshipper -n #{logshipper_fifo_path} >> /var/log/logshipper.log 2>&1"

# differentiate here the platform-specific parts

# generic (tested on ubuntu)
upstart_script = %Q(
  start on starting rsyslog
  stop on stopped rsyslog

  setuid logshipper
  setgid conjur

  exec #{command_line}
)

# workarounds
case node['platform_family']
when 'rhel'
  upstart_script = %Q(
    # rsyslog isn't upstarted here
    start on (local-filesystems and net-device-up IFACE!=lo)
    stop on runlevel [016]

    # old upstart, no set[ug]id stanzas
    exec runuser -s /bin/bash logshipper -g conjur -- -c "#{command_line}"
  )
end

file '/etc/init/logshipper.conf' do
  content %Q(
    description "Conjur log shipping agent"

    respawn

    # workaround a bug in logshipper 0.1.0
    env HOME=/etc
  ) + upstart_script
end
