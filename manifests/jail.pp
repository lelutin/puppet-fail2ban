define fail2ban::jail (
  $port,
  $filter,
  $logpath,
  $ensure    = present,
  $enabled   = 'true',
  $protocol  = false,
  $maxretry  = false,
  $findtime  = false,
  $action    = false,
  $banaction = false,
  $ignoreip  = false,
  $order     = false,
) {
  include fail2ban::config

  concat::fragment { "jail_${name}":
    ensure  => $ensure,
    target  => '/etc/fail2ban/jail.local',
    content => template('fail2ban/jail.erb'),
  }

  if $order != false {
    Concat::Fragment["jail_${name}"] {
      order => $order,
    }
  }

}
