# Setup a fail2ban jail.
define fail2ban::jail (
  $port,
  $filter,
  $logpath,
  $ensure    = present,
  $enabled   = true,
  $protocol  = false,
  $maxretry  = false,
  $findtime  = false,
  $action    = false,
  $banaction = false,
  $bantime   = false,
  $ignoreip  = false,
  $order     = false,
) {
  include fail2ban::config

  if $ensure != present {
    warning('The $ensure parameter is now deprecated! to ensure that a fail2ban jail is absent, simply remove the resource.')
  }

  concat::fragment { "jail_${name}":
    target  => '/etc/fail2ban/jail.local',
    content => template('fail2ban/jail.erb'),
  }

  if $order != false {
    Concat::Fragment["jail_${name}"] {
      order => $order,
    }
  }

}
