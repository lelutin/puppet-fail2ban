# Setup a fail2ban jail.
#
define fail2ban::jail (
  Variant[Integer, String] $port,
  String $filter,
  Variant[Boolean, String] $logpath = false,
  Enum['present','absent'] $ensure = 'present',
  Boolean $enabled = true,
  Variant[Boolean, Enum['tcp','udp','icmp','all']] $protocol = false,
  Variant[Boolean, Integer] $maxretry = false,
  Variant[Boolean, Integer] $findtime = false,
  Variant[Boolean, String] $ignorecommand = false,
  Variant[Boolean, String] $action = false,
  Variant[Boolean, String] $banaction = false,
  Variant[Boolean, Integer] $bantime = false,
  Array[String, 0] $ignoreip = [],
  Variant[Boolean, Enum['auto','pyinotify','gamin','polling','systemd']] $backend = false,
) {
  include fail2ban::config

  if $backend == 'systemd' {
    if $logpath {
      fail('logpath must not be set when $backend is \'systemd\'')
    }
  }
  else {
    if $logpath == false {
      fail('logpath must be set unless $backend is \'systemd\'')
    }
  }

  if $port == 'all' {
    $portrange = '1:65535'
  }
  else
  {
    $portrange = $port
  }

  file { "/etc/fail2ban/jail.d/${name}.conf":
    ensure  => $ensure,
    content => template('fail2ban/jail.erb'),
    owner   => 'root',
    group   => 0,
    mode    => '0644',
    notify  => Class['fail2ban::service']
  }

}
